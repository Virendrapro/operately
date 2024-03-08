defmodule Operately.Activities.Content.GoalCheckInCommented do
  use Operately.Activities.Content

  embedded_schema do
    field :company_id, :string
    field :goal_id, :string
    field :goal_check_in_id, :string
    field :comment_id, :string
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, __schema__(:fields))
    |> validate_required(__schema__(:fields))
  end

  def build(params) do
    changeset(params)
  end
end