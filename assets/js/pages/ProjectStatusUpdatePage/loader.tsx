import client from "@/graphql/client";

import * as Paper from "@/components/PaperContainer";

import * as Me from "@/graphql/Me";
import * as Projects from "@/graphql/Projects";
import * as People from "@/graphql/People";
import * as Updates from "@/graphql/Projects/updates";

interface LoaderResult {
  project: Projects.Project;
  update: Updates.Update;
  me: People.Person;
}

export async function loader({ params }): Promise<LoaderResult> {
  let projectDate = await client.query({
    query: Projects.GET_PROJECT,
    variables: { id: params.projectID },
    fetchPolicy: "network-only",
  });

  let updateData = await client.query({
    query: Updates.GET_STATUS_UPDATE,
    variables: { id: params.id },
    fetchPolicy: "network-only",
  });

  let meData = await client.query({
    query: Me.GET_ME,
    fetchPolicy: "network-only",
  });

  return {
    project: projectDate.data.project,
    update: updateData.data.update,
    me: meData.data.me,
  };
}

export function useLoadedData(): LoaderResult {
  const [data, _] = Paper.useLoadedData() as [LoaderResult, () => void];

  return data;
}

export function usePageRefetch(): () => void {
  const [_data, refetch] = Paper.useLoadedData() as [LoaderResult, () => void];

  return refetch;
}
