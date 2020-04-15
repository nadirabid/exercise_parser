import React, { useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Box from '@material-ui/core/Box';
import Button from '@material-ui/core/Button';
import List from '@material-ui/core/List';
import CardContent from '@material-ui/core/CardContent';
import Skeleton from '@material-ui/lab/Skeleton';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import * as auth from './auth';

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
    flexGrow: 0,
    flexDirection: 'column',
    display: 'flex',
    borderRight: 'solid 1px #444',
  },
  logout: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: '6px',
  },
  content: {
    flexGrow: 1,
    alignItems: 'stretch',
  },
  list: {
    display: 'flex',
    alignItems: 'stretch',
    flexDirection: 'column',
    maxHeight: '100vh',
    overflowY: 'scroll',
  },
  listItem: {
    backgroundColor: theme.palette.background.paper,
    marginTop: '6px',
  }
}));

async function fetchUnresolvedExercises() {
  const result = await fetch(`${auth.getAPIUrl()}/api/exercise/unresolved`);

  if (result.status != 200) {
    console.error('Failed to sign in', result);
    return false;
  }

  const resp = await result.json();

  return resp;
}

function ExerciseListItems({ list }) {
  const classes = useStyles();

  if (list == null) {
    return [0,1,2,3].map(() => (
      <CardContent>
          <Skeleton animation="wave"/>
          <Skeleton width="60%" animation="wave"/>
      </CardContent>
    ));
  }

  return [list.results].map((item) => (
    <ListItem className={classes.listItem}>
      <ListItemText width="100%" primary={JSON.stringify(item)} />
    </ListItem>
  ));
}

function Console() {
  const classes = useStyles();

  const [list, setList] = React.useState(null);
  
  useEffect(() => {
    fetchUnresolvedExercises().then((list) => setList(list));
  }, []);

  return (
    <div className={classes.root}>
      <Box className={classes.sidebar}>
        <Box className={classes.title}>
          <h2>console</h2>
        </Box>
        <Box flex="1"></Box>
        <Box flex="0" className={classes.logout}>
          <Button 
            onClick={() => {
              auth.signOut()
            }}
          >
            Logout
          </Button>
        </Box>
      </Box>
      <Box className={classes.content}>
        <List className={classes.list} style={{overflow: 'auto'}}>
          <ExerciseListItems list={list} />
        </List>
      </Box>
    </div>
  );
}

export default Console;
