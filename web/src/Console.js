import React from 'react';

import { makeStyles } from '@material-ui/core/styles';
import Box from '@material-ui/core/Box';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';
import DashboardIcon from '@material-ui/icons/Dashboard';

import * as auth from './auth';
import ExercisePanel from './ExercisePanel';

const useStyles = makeStyles((theme) => ({
  root: {
    display: 'flex',
    height: '100%',
    flexDirection: 'row',
    alignItems: 'stretch',
  },
  menuButton: {
    marginRight: theme.spacing(2),
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
}));

function Console() {
  const classes = useStyles();

  return (
    <div className={classes.root}>
      <Box className={classes.sidebar}>
        <Box className={classes.title}>
        <DashboardIcon />
          <Typography variant="h5">console</Typography>
        </Box>
        <Box flex="1"></Box>
        <Box flex="0" className={classes.logout}>
          <Button onClick={() => auth.signOut()}>
            Logout
          </Button>
        </Box>
      </Box>
      <ExercisePanel />
    </div>
  );
}

export default Console;
