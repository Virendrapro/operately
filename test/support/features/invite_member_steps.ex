defmodule Operately.Support.Features.InviteMemberSteps do
  use Operately.FeatureCase

  alias Operately.Support.Features.UI
  alias Operately.Companies

  import Operately.CompaniesFixtures
  import Operately.PeopleFixtures
  import Operately.InvitationsFixtures

  step :given_that_a_company_and_an_admin_exists, ctx do
    company = company_fixture()
    creator = hd(Companies.list_admins(company.id))

    admin = person_fixture_with_account(%{company_id: company.id, full_name: "John Admin"})
    Companies.add_admin(creator, admin.id)

    Map.merge(ctx, %{company: company, admin: admin})
  end

  step :log_in_as_admin, ctx do
    ctx |> UI.login_as(ctx.admin)
  end

  step :navigate_to_invitation_page, ctx do
    ctx
    |> UI.visit(Paths.home_path(ctx.company))
    |> UI.click(testid: "company-dropdown")
    |> UI.click(testid: "company-dropdown-company-admin")
    |> UI.click(testid: "manage-team-members")
    |> UI.click(testid: "add-person")
  end

  step :invite_member, ctx, params do
    ctx
    |> UI.fill(testid: "person-full-name", with: params[:fullName])
    |> UI.fill(testid: "person-email", with: params[:email])
    |> UI.fill(testid: "person-title", with: params[:title])
    |> UI.click(testid: "submit")
  end

  step :submit_password, ctx, password do
    ctx
    |> UI.fill(testid: "password", with: password)
    |> UI.fill(testid: "passwordConfirmation", with: password)
    |> UI.click(testid: "submit")
    |> UI.assert_has(testid: "company-home")
  end

  step :reissue_invitation_token, ctx, name do
    person = Operately.People.get_person_by_name!(ctx.company, name)

    ctx 
    |> UI.visit(Paths.company_admin_path(ctx.company))
    |> UI.click(testid: "manage-team-members")
    |> UI.click(testid: UI.testid(["person-options", Paths.person_id(person)]))
    |> UI.click(testid: UI.testid(["reissue-token", Paths.person_id(person)]))
    |> UI.click(testid: "confirm-reissue")
  end

  step :assert_member_invited, ctx do
    ctx |> UI.assert_text("/join?token=")
  end

  step :given_that_I_was_invited_and_have_a_token, ctx, params do
    member = person_fixture_with_account(%{company_id: ctx.company.id, full_name: params[:name], email: params[:email]})
    invitation = invitation_fixture(%{member_id: member.id, admin_id: ctx.admin.id})
    token = invitation_token_fixture_unhashed(invitation.id)

    ctx 
    |> Map.put(:token, token) 
    |> Map.put(:person, member)
  end

  step :given_that_an_invitation_was_sent, ctx, params do
    member = person_fixture_with_account(%{
      company_id: ctx.company.id, 
      full_name: params[:name], 
      email: params[:email],
      has_open_invitation: true
    })

    invitation = invitation_fixture(%{member_id: member.id, admin_id: ctx.admin.id})
    token = invitation_token_fixture_unhashed(invitation.id)

    ctx 
    |> Map.put(:token, token) 
    |> Map.put(:person, member)
  end

  step :goto_invitation_page, ctx do
    ctx
    |> UI.logout()
    |> UI.visit("/join?token=#{ctx.token}")
    |> UI.assert_text("Welcome to Operately")
    |> UI.assert_text("Choose a password")
    |> UI.assert_text("Repeat password")
  end

  step :assert_password_set_for_new_member, ctx, params do
    account = Operately.People.get_account_by_email_and_password(params[:email], params[:password])
    person = Operately.Repo.preload(account, :people).people |> hd()

    assert is_struct(account, Operately.People.Account)
    assert person.email == params[:email]

    ctx
  end

  step :given_that_an_invitation_was_sent_and_expired, ctx, params do
    member = person_fixture_with_account(%{
      company_id: ctx.company.id, 
      full_name: params[:name], 
      email: params[:email],
      has_open_invitation: true
    })

    invitation = invitation_fixture(%{member_id: member.id, admin_id: ctx.admin.id})
    invitation_token_fixture_unhashed(invitation.id)

    invitation = Operately.Repo.preload(invitation, :invitation_token)

    {:ok, _} = Operately.Repo.update(Ecto.Changeset.change(invitation.invitation_token, %{
      valid_until: DateTime.add(DateTime.utc_now(), -4, :day) |> DateTime.truncate(:second)
    }))

    ctx |> Map.put(:member, member)
  end

  step :assert_an_expired_warning_is_shown_on_the_team_page, ctx do
    ctx
    |> UI.visit(Paths.company_admin_path(ctx.company))
    |> UI.click(testid: "manage-team-members")
    |> UI.assert_text("Invitation Expired")
  end

  step :renew_invitation, ctx, name do
    person = Operately.People.get_person_by_name!(ctx.company, name)

    ctx 
    |> UI.click(testid: UI.testid(["renew-invitation", Paths.person_id(person)]))
    |> UI.assert_text("/join?token=")
  end

  step :assert_invitation_renewed, ctx do
    member = Operately.People.get_person!(ctx.member.id)
    member = Operately.Repo.preload(member, [invitation: :invitation_token])

    assert member.invitation.invitation_token.valid_until > DateTime.utc_now()
  end
end
