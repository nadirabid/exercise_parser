import React, { useEffect } from 'react';
import ReactJson from 'react-json-view'
import { makeStyles } from '@material-ui/core/styles';
import Box from '@material-ui/core/Box';
import Button from '@material-ui/core/Button';
import List from '@material-ui/core/List';
import CardContent from '@material-ui/core/CardContent';
import Skeleton from '@material-ui/lab/Skeleton';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import Pagination from '@material-ui/lab/Pagination';
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
    marginBottom: '6px',
  },
  content: {
    flexGrow: 1,
    alignItems: 'stretch',
    display: 'flex',
  },
  list: {
    display: 'flex',
    alignItems: 'stretch',
    flexDirection: 'column',
    maxHeight: '100vh',
    overflowY: 'scroll',
    flex: 1,
  },
  listItem: {
    backgroundColor: theme.palette.background.paper,
    marginTop: '6px',
  },
  pagination: {
    flex: 0,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    '& li': {
      marginTop: '1em'
    }
  }
}));

const rjvTheme =  {
  base00: 'rgba(1, 1, 1, 0)',
  base01: 'rgba(0, 0, 0, 0.05)',
  base02: 'rgba(0, 0, 0, 0.1)',
  base03: '#93a1a1',
  base04: 'rgba(0, 0, 0, 0.3)',
  base05: '#586e75',
  base06: '#073642',
  base07: '#002b36',
  base08: '#d33682',
  base09: '#cb4b16',
  base0A: '#dc322f',
  base0B: '#859900',
  base0C: '#6c71c4',
  base0D: '#586e75',
  base0E: '#2aa198',
  base0F: '#268bd2'
};

const solarizedTheme = {
  base00: 'rgba(1, 1, 1, 0)',
  base01:"#073642",
  base02:"#586e75",
  base03:"#657b83",
  base04:"#839496",
  base05:"#93a1a1",
  base06:"#eee8d5",
  base07:"#fdf6e3",
  base08:"#dc322f",
  base09:"#cb4b16",
  base0A:"#b58900",
  base0B:"#859900",
  base0C:"#2aa198",
  base0D:"#268bd2",
  base0E:"#6c71c4",
  base0F:"#d33682"
}

async function fetchUnresolvedExercises(page = 1, pageSize=20) {
  const result = await fetch(`${auth.getAPIUrl()}/api/exercise/unresolved?size=${pageSize}&page=${page}`);

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
      <ReactJson iconStyle="circle" theme={solarizedTheme} src={item} />
    </ListItem>
  ));
}

function Console() {
  const classes = useStyles();

  const [list, setList] = React.useState(null);
  
  useEffect(() => {
    fetchUnresolvedExercises(0).then((list) => setList(list));
  }, []);

  const handleChange = (event, value) => {
    fetchUnresolvedExercises(value - 1).then((list) => setList(list));
  }

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
        <div className={classes.pagination}>
          <Pagination 
            variant="outlined" size="large" showFirstButton showLastButton 
            disabled={list == null || list.pages <= 1}
            count={list == null ? 6 : list.pages} 
            page={list == null ? 0 : list.page}
          />
        </div>
      </Box>
    </div>
  );
}

export default Console;
