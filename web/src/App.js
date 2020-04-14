import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import CssBaseline from '@material-ui/core/CssBaseline';

import { createMuiTheme, ThemeProvider } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
  },
  menuButton: {
    marginRight: theme.spacing(2),
  },
  title: {
    flexGrow: 1,
  },
}));

const darkTheme = createMuiTheme({
  palette: {
    type: 'dark'
  }
});

function signIn() {
  const params = {
    'response_type': 'code',
    'redirect_uri': 'https://rydenfitness.com/apple/callback',
    'client_id': 'ryden.web',
    'scope': 'email name',
    'response_mode': 'form_post'
  };

  const paramsStr = Object.entries(params).reduce((str, [key, value]) => {
    if (str !== '') {
      str += '&'
    }

    return `${str}${key}=${value}`;
  }, '');

  window.location.href = `https://appleid.apple.com/auth/authorize?${paramsStr}`;
}

function App() {
  const classes = useStyles();

  return (
    <ThemeProvider theme={darkTheme}>
      <CssBaseline />
      <AppBar position="static" color="inherit">
        <Toolbar color="inherit">
          <Typography variant="h5" color="inherit" className={classes.title}>
            ryden
          </Typography>
          <Button onClick={signIn} color="inherit">Login</Button>
        </Toolbar>
      </AppBar>
    </ThemeProvider>
  );
}

export default App;
