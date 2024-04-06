import * as React from "react";
import * as Goals from "@/models/goals";

import { Tree, SortColumn, SortDirection, TreeFilters } from "./tree";

export type ExpandedNodesMap = Record<string, boolean>;

export interface TreeContextValue {
  tree: Tree;

  expanded: ExpandedNodesMap;
  toggleExpanded: (id: string) => void;
  expandAll: () => void;
  collapseAll: () => void;

  sortColumn: SortColumn;
  sortDirection: SortDirection;
  setSortColumn: (column: SortColumn) => void;
  setSortDirection: (direction: SortDirection) => void;

  hideSpaceColumn?: boolean;

  showCompleted: boolean;
  setShowCompleted: (show: boolean) => void;
}

const TreeContext = React.createContext<TreeContextValue | null>(null);

export interface TreeContextProviderProps {
  goals: Goals.Goal[];
  filters?: TreeFilters;
  hideSpaceColumn?: boolean;
}

interface TreeContextProviderPropsWithChildren extends TreeContextProviderProps {
  children: React.ReactNode;
}

export function TreeContextProvider(props: TreeContextProviderPropsWithChildren) {
  const [sortColumn, setSortColumn] = React.useState<SortColumn>("progress");
  const [sortDirection, setSortDirection] = React.useState<SortDirection>("desc");
  const [showCompleted, setShowCompleted] = React.useState<boolean>(false);

  const tree = React.useMemo(
    () => new Tree(props.goals, sortColumn, sortDirection, props.filters || {}, showCompleted),
    [props.goals, sortColumn, sortDirection, props.filters, showCompleted],
  );

  const { expanded, toggleExpanded, expandAll, collapseAll } = useExpandedNodesState(tree);

  const value = {
    tree,
    expanded,
    toggleExpanded,
    expandAll,
    collapseAll,
    sortColumn,
    setSortColumn,
    setSortDirection,
    sortDirection,
    hideSpaceColumn: props.hideSpaceColumn,
    showCompleted,
    setShowCompleted,
  };

  return <TreeContext.Provider value={value}>{props.children}</TreeContext.Provider>;
}

export function useTreeContext() {
  const context = React.useContext(TreeContext);
  if (!context) {
    throw new Error("useTreeContext must be used within a TreeProvider");
  }
  return context;
}

export function useExpandedNodesState(tree: Tree) {
  const [expanded, setExpanded] = React.useState<ExpandedNodesMap>({});

  const toggleExpanded = (id: string) => {
    setExpanded((prev) => ({ ...prev, [id]: !prev[id] }));
  };

  const expandAll = () => {
    setExpanded(tree.getAllNodes().reduce((acc, node) => ({ ...acc, [node.id]: true }), {}));
  };

  const collapseAll = () => {
    setExpanded({});
  };

  return {
    expanded,
    toggleExpanded,
    expandAll,
    collapseAll,
  };
}
