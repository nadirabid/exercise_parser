import { makeStyles } from '@material-ui/core/styles';
import React from 'react';
import Typography from '@material-ui/core/Typography';

const useStyles = makeStyles((theme) => ({
  root: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    height: '100%',
    backgroundColor: theme.palette.app.primary,
  },
  mainText: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  },
  typoHeaderPrimary: {
    letterSpacing: '0.2em',
    fontWeight: theme.typography.fontWeightBold,
    color: '#fff',
  },
  typoHeaderSecondary: {
    fontWeight: theme.typography.fontWeightBold,
    color: theme.palette.app.secondary,
  },
}));

function App() {
  const classes = useStyles();

  return (
    <div className={classes.root}>
        <div className={classes.mainText}>
          <Typography className={classes.typoHeaderSecondary} variant="h4" noWrap={true} fontWeight="fontWeightBold">FOR THE ATHLETES</Typography>
          <Typography className={classes.typoHeaderPrimary} variant="h1" noWrap={true} fontWeight="fontWeightBold">RYDEN</Typography>
          <Typography className={classes.typoHeaderSecondary} variant="h4" noWrap={true} fontWeight="fontWeightBold">FORM & WILL</Typography>
        </div>
    </div>
  );
}

export default App;
