import React, { useState, useEffect } from 'react';

import ReactJson from 'react-json-view';

import { makeStyles } from '@material-ui/core/styles';
import Box from '@material-ui/core/Box';
import Button from '@material-ui/core/Button';
import List from '@material-ui/core/List';
import CardContent from '@material-ui/core/CardContent';
import Skeleton from '@material-ui/lab/Skeleton';
import ListItem from '@material-ui/core/ListItem';
import Pagination from '@material-ui/lab/Pagination';
import Slide from '@material-ui/core/Slide';
import Typography from '@material-ui/core/Typography';
import AssessmentIcon from '@material-ui/icons/Assessment';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import { ThemeProvider } from '@material-ui/core/styles';

import * as auth from './auth';
import ExerciseSearch from './ExerciseSearch';
import { darkTheme } from './globals';

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
  base0F:"#d33682",
};

const Transition = React.forwardRef(function Transition(props, ref) {
  return <Slide direction="up" ref={ref} {...props} />;
});

const useStyles = makeStyles((theme) => ({
  content: {
    flexGrow: 1,
    alignItems: 'stretch',
    display: 'flex',
    flexDirection: 'column',
  },
  pagination: {
    flex: 0,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    '& li': {
      marginTop: theme.spacing(1),
    },
  },
  listContent: {
    flexGrow: 1,
    alignItems: 'stretch',
    display: 'flex',
    flexDirection: 'row',
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
    marginTop: theme.spacing(1),
    marginBottom: theme.spacing(1),
    marginRight: theme.spacing(3),
    marginLeft: theme.spacing(3),
    display: 'flex',
    width: 'auto',
    '& > *:not(:first-child)': {
      marginLeft: theme.spacing(4),
    },
    '& > *:first-child': {
      flex: 0,
      overflow: 'none',
      whiteSpace: 'nowrap',
    },
    '& > *:nth-child(2)': {
      flex: 1,
    },
    '& > *:nth-child(3)': {
      flex: 0,
    },
  },
  data: {
    display: 'flex',
    flexDirection: 'column',
    '& > *': {
      marginTop: theme.spacing(1),
      width: '100%'
    },
  },
  dialog: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: theme.spacing(2)
  },
  dialogContent: {
    display: 'flex'
  },
  toolbar: {
    display: 'flex',
  },
  toolbarTitle: {
    flex: '1',
  },
  toolbarSearch: {
    flex: '0',
  },
}));

async function getAPIDictionaryRelatedNames(dictionaryId, page = 1, pageSize=20) {
  const result = await fetch(`${auth.getAPIUrl()}/api/exercise/dictionary/${dictionaryId}/related?size=${pageSize}&page=${page}`);

  if (result.status !== 200) {
    console.error('Failed to sign in', result);
    return false;
  }

  const resp = await result.json();

  return resp;
}

function RelatedNamesListItems({ list, onItemClick = () => {} }) {
  const classes = useStyles();

  if (list == null) {
    return [0,1,2,3].map((v) => (
      <CardContent key={v.toString()}>
          <Skeleton animation="wave"/>
          <Skeleton width="60%" animation="wave"/>
      </CardContent>
    ));
  }

  return list.results.map((item, index) => (
    <ListItem key={`exercise-${index}`} className={classes.listItem}>
      <h3>{item.related}</h3>
      <div>
        <ReactJson iconStyle="circle" theme={solarizedTheme} src={item} collapsed={true} />
      </div>
    </ListItem>
  ));
}

function DictionaryRelatedNamesPanel() {
  const classes = useStyles();

  const [list, setList] = useState(null);
  const [exerciseDictionary, setExerciseDictionary] = useState(null);
  
  useEffect(() => {
    if (exerciseDictionary) {
      getAPIDictionaryRelatedNames(exerciseDictionary.exercise_dictionary_id)
        .then((result) => setList(result))
    }
  }, exerciseDictionary);

  const pageChange = (_, value) => {
    getAPIDictionaryRelatedNames(exerciseDictionary.exercise_dictionary_id, value - 1)
        .then((result) => setList(result))
  };

  console.log(exerciseDictionary)
  return (
    <Box className={classes.content}>
      <ThemeProvider theme={darkTheme}>
        <AppBar position="sticky">
          <Toolbar className={classes.toolbar}>
            <Typography className={classes.toolbarTitle} component="h3" variant="h7">Related Names</Typography>
            <ExerciseSearch className={classes.toolbarSearch} onSelect={(e) => setExerciseDictionary(e)} />
          </Toolbar>
        </AppBar>
      </ThemeProvider>

      <Box className={classes.listContent}>
        <List className={classes.list} style={{overflow: 'auto'}}>
          <RelatedNamesListItems list={list} />
        </List>
        <div className={classes.pagination}>
          <Pagination
            variant="outlined" size="large" showFirstButton showLastButton 
            onChange={pageChange}
            disabled={list == null || list.pages <= 1}
            count={list == null ? 6 : list.pages} 
            page={list == null ? 0 : list.page}
          />
        </div>
      </Box>
    </Box>
  );
}

export default DictionaryRelatedNamesPanel;
