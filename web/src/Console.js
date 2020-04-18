import React, { useState } from 'react';

import { makeStyles } from '@material-ui/core/styles';
import Box from '@material-ui/core/Box';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import DashboardIcon from '@material-ui/icons/Dashboard';
import TreeView from '@material-ui/lab/TreeView';
import TreeItem from '@material-ui/lab/TreeItem';

import * as auth from './auth';
import UnresolvedExercisePanel from './UnresolvedExercisePanel';
import UnmatchedExercisePanel from './UnmatchedExercisePanel';

const useStyles = makeStyles((theme) => ({
  root: {
    display: 'flex',
    height: '100%',
    flexDirection: 'row',
    alignItems: 'stretch',
  },
  title: {
    borderBottom: 'solid 1px #444',
    height: '60px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    color: '#F8481C',
  },
  sidebar: {
    width: '220px',
    minWidth: '220px',
    maxWidth: '220px',
    flexGrow: 0,
    flexDirection: 'column',
    display: 'flex',
    borderRight: 'solid 1px #444',
  },
  logout: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: theme.spacing(1),
  },
  treeView: {
    height: '240px',
    flexGrow: 1,
    maxWidth: '400px',
  },
}));

// hijacked from material ui theme - this is bullshit frankly
const useTreeItemStyles = makeStyles((theme) => ({
  root: {
    color: theme.palette.text.secondary,
    '&:hover > $content': {
      backgroundColor: theme.palette.action.hover,
    },
    '&:focus > $content, &$selected > $content': {
      backgroundColor: `var(--tree-view-bg-color, ${theme.palette.grey[400]})`,
      color: 'var(--tree-view-color)',
    },
    '&:focus > $content $label, &:hover > $content $label, &$selected > $content $label': {
      backgroundColor: 'transparent',
    },
    '&$selected > $content $label:hover, &$selected:focus > $content $label': {
      backgroundColor: 'transparent',
    }
  },
  content: {
    color: theme.palette.text.secondary,
    borderTopRightRadius: theme.spacing(0),
    borderBottomRightRadius: theme.spacing(0),
    paddingRight: theme.spacing(1),
    paddingTop: theme.spacing(1),
    paddingBottom: theme.spacing(1),
    fontWeight: theme.typography.fontWeightMedium,
    '$expanded > &': {
      fontWeight: theme.typography.fontWeightRegular,
    },
  },
  group: {
    marginLeft: 0,
    '& $content': {
      paddingLeft: theme.spacing(2),
    },
  },
  expanded: {},
  selected: {},
  label: {
    fontWeight: 'inherit',
  },
  labelRoot: {
    display: 'flex',
    alignItems: 'center',
    padding: theme.spacing(0.5, 0),
  },
  labelIcon: {
    marginRight: theme.spacing(1),
  },
  labelText: {
    fontWeight: 'inherit',
    flexGrow: 1,
  },
}));

function Sidebar({ onSelect = () => {} }) {
  const classes = useStyles();
  const treeItemClasses = useTreeItemStyles();

  const [selected, setSelected] = useState("exercises.unresolved");
  const [expanded, setExpanded] = useState("exercises");

  const classObj = {
    root: treeItemClasses.root,
    content: treeItemClasses.content,
    expanded: treeItemClasses.expanded,
    selected: treeItemClasses.selected,
    group: treeItemClasses.group,
    label: treeItemClasses.label,
  };

  const handleSelect = (_, value) => {
    if (selected.includes("exercises")) {
      setExpanded("exercises");
    }

    if (selected.includes(".")) {
      setSelected(value);
      onSelect(value);
    }
  };
  
  return (
    <Box className={classes.sidebar}>
      <Box className={classes.title}>
      <DashboardIcon />
        <Typography variant="h5">console</Typography>
      </Box>
      <Box flex="1">
        <TreeView expanded={[expanded]} selected={selected} onNodeSelect={handleSelect}>
          <TreeItem 
            classes={classObj} nodeId="exercises" 
            label={
              <Typography variant="h7">Exercises</Typography>
            }
          >
            <TreeItem 
              classes={classObj} nodeId="exercises.unresolved"
              label={
                <Typography variant="h7">Unresolved</Typography>
              }
            />
            <TreeItem 
              classes={classObj} nodeId="exercises.unmatched" 
              label={
                <Typography variant="h7">Unmatched</Typography>
              } 
            />
          </TreeItem>
        </TreeView>
      </Box>
      <Box flex="0" className={classes.logout}>
        <Button onClick={() => auth.signOut()}>
          Logout
        </Button>
      </Box>
    </Box>
  );
}

function Console() {
  const classes = useStyles();

  const [selectedPanel, setSelectedPanel] = useState("exercises.unresolved");

  let panel;
  if (selectedPanel === "exercises.unresolved") {
    panel = <UnresolvedExercisePanel />;
  } else if (selectedPanel === "exercises.unmatched") {
    panel = <UnmatchedExercisePanel />;
  }

  return (
    <div className={classes.root}>
      <Sidebar onSelect={setSelectedPanel} />
      {panel}
    </div>
  );
}

export default Console;
