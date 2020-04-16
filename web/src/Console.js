import React, { useEffect } from 'react';
import ReactJson from 'react-json-view'
import { makeStyles } from '@material-ui/core/styles';
import Box from '@material-ui/core/Box';
import Button from '@material-ui/core/Button';
import ToggleButton from '@material-ui/lab/ToggleButton';
import ToggleButtonGroup from '@material-ui/lab/ToggleButtonGroup';
import Autocomplete from '@material-ui/lab/Autocomplete';
import List from '@material-ui/core/List';
import Backdrop from '@material-ui/core/Backdrop';
import CardContent from '@material-ui/core/CardContent';
import Skeleton from '@material-ui/lab/Skeleton';
import ListItem from '@material-ui/core/ListItem';
import TextField from '@material-ui/core/TextField';
import Pagination from '@material-ui/lab/Pagination';
import Slide from '@material-ui/core/Slide';
import Dialog from '@material-ui/core/Dialog';
import DialogContent from '@material-ui/core/DialogContent';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogActions from '@material-ui/core/DialogActions';
import Typography from '@material-ui/core/Typography';
import FitnessCenterIcon from '@material-ui/icons/FitnessCenter';
import DirectionsRunIcon from '@material-ui/icons/DirectionsRun';
import DashboardIcon from '@material-ui/icons/Dashboard';
import AssessmentIcon from '@material-ui/icons/Assessment';

import * as auth from './auth';

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
};

const Transition = React.forwardRef(function Transition(props, ref) {
  return <Slide direction="up" ref={ref} {...props} />;
});

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
  content: {
    flexGrow: 1,
    alignItems: 'stretch',
    display: 'flex',
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
    margin: '2em',
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
  }
}));

async function getAPIUnresolvedExercises(page = 1, pageSize=20) {
  const result = await fetch(`${auth.getAPIUrl()}/api/exercise/unresolved?size=${pageSize}&page=${page}`);

  if (result.status != 200) {
    console.error('Failed to sign in', result);
    return false;
  }

  const resp = await result.json();

  return resp;
}

async function updateAPIExercise(exercise) {
  
}

function UpdaterExercise({ exercise, onCancel = () => {}, onSave = () => {} }) {
  const classes = useStyles();

  const [exerciseType, setExerciseType] = React.useState('weighted');
  const [sets, setSets] = React.useState(0);
  const [reps, setReps] = React.useState(0);
  const [weight, setWeight] = React.useState(0);

  const [time, setTime] = React.useState(0);
  const [distance, setDistance] = React.useState(0);

  const shouldOpen = exercise != null;
  if (exercise == null) {
    exercise = {}
  }

  const handleUpdate = () => {
    const data = JSON.parse(JSON.stringify(exercise));

    data.type = exerciseType;

    if (exerciseType === 'weighted') {
      data['weighted_exercise'] = {
        'sets': sets,
        'reps': reps,
        'weight': weight,
      };
    } else if (exerciseType === 'distance_exercise') {
      data['distance_exercise'] = {
        'distance': distance,
        'time': time
      };
    }

    onSave(data); 
  };

  let fields = null;

  if (exerciseType === 'weighted') {
    fields = (
      <div className={classes.data}>
        <Box>
          <TextField variant="filled" label="Sets" 
            value={sets} onChange={(e) => setSets(e.target.value)} 
          />
        </Box>
        <Box>
          <TextField variant="filled" label="Reps"
            value={reps} onChange={(e) => setReps(e.target.value)}
          />
        </Box>
        <Box>
          <TextField variant="filled" label="Weight" 
            value={weight} onChange={(e) => setWeight(e.target.value)}
          />
        </Box>
      </div>
    );
  } else if (exerciseType === 'distance') {
    fields = (
      <div className={classes.data}>
        <Box>
          <TextField variant="filled" label="Time" 
            value={time} onChange={(e) => setTime(e.target.value)}
          />
        </Box>
        <Box>
          <TextField variant="filled" label="Distance" 
            value={distance} onChange={(e) => setDistance(e.target.value)}
          />
        </Box>
      </div>
    );
  }

  return (
    <Dialog
      open={shouldOpen}
      closeAfterTransition
      BackdropComponent={Backdrop}
      TransitionComponent={Transition}
      BackdropProps={{
        timeout: 500,
      }}
      onClose={onCancel}
    >
      <DialogTitle>{exercise.raw}</DialogTitle>
      <DialogContent className={classes.dialogContent}>
        <div> 
          <Autocomplete
            options={[]}
            style={{ width: 300 }}
            renderInput={(params) => {
              return (<TextField {...params} label="Exercise Name" variant="outlined" />);
            }}
          />
        </div>
        <div>
          <ToggleButtonGroup
            value={exerciseType}
            exclusive
            onChange={(e, v) => setExerciseType(v)}
            aria-label="text alignment"
          >
            <ToggleButton value="weighted" aria-label="left aligned">
              <FitnessCenterIcon />
            </ToggleButton>
            <ToggleButton value="distance" aria-label="centered">
              <DirectionsRunIcon />
            </ToggleButton>
          </ToggleButtonGroup>

          {fields}
        </div>
      </DialogContent>
      <DialogActions>
        <Button variant="outlined" onClick={onCancel}>Cancel</Button>
        <Button variant="outlined" onClick={onSave}>Update</Button>
      </DialogActions>
    </Dialog>
  )
}

function ExerciseListItems({ list, onItemClick = () => {} }) {
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
      <h3>{item.raw}</h3>
      <div>
        <ReactJson iconStyle="circle" theme={solarizedTheme} src={item} collapsed={true} />
      </div>
      <Button onClick={() => onItemClick(item)} variant="outlined" color="default">
        <AssessmentIcon />
      </Button>
    </ListItem>
  ));
}

function Console() {
  const classes = useStyles();

  const [list, setList] = React.useState(null);
  const [exercise, setExercise] = React.useState(null);
  
  useEffect(() => {
    getAPIUnresolvedExercises(0).then((list) => setList(list));
  }, []);

  const pageChange = (event, value) => {
    getAPIUnresolvedExercises(value - 1).then((list) => setList(list));
  };

  return (
    <div className={classes.root}>
      <UpdaterExercise exercise={exercise} onCancel={() => setExercise(null)} />
      <Box className={classes.sidebar}>
        <Box className={classes.title}>
        <DashboardIcon />
          <Typography variant="h5">console</Typography>
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
          {/* <ListSubheader className={classes.listItem}>
            <Typography variant="h7">unresolved exercises</Typography>
          </ListSubheader> */}
          <ExerciseListItems list={list} onItemClick={(item) => setExercise(item)} />
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
    </div>
  );
}

export default Console;
