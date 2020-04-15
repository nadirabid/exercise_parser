import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import CssBaseline from '@material-ui/core/CssBaseline';
import Modal from '@material-ui/core/Modal';
import Backdrop from '@material-ui/core/Backdrop';
import Fade from '@material-ui/core/Fade';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import Skeleton from '@material-ui/lab/Skeleton';
import Paper from '@material-ui/core/Paper';
import Box from '@material-ui/core/Box'

import { createMuiTheme, ThemeProvider } from '@material-ui/core/styles';

function getAPIUrl() {
  const tls = process.env.REACT_APP_TLS;
  const domain = process.env.REACT_APP_API_URL;
  if (tls === 'enabled') {
    return `https://${domain}`;
  }
  
  return `http://${domain}`;
}

function isAuthenticated() {
  var urlParams = new URLSearchParams(window.location.search);

  if (urlParams.has('id_token')) {
    localStorage.setItem('jwt_token', urlParams.get('id_token'));
  }

  let token = localStorage.getItem('jwt_token');
  if (token === null) {
    return false;
  }

  return true;
}

function isAuthEnabled() {
  if (process.env.REACT_APP_AUTH === 'disabled') {
    return false;
  }

  return true;
}

function signInWithApple() {
  const params = {
    'response_type': 'code',
    'redirect_uri': 'https://rydenfitness.com/apple/callback',
    'client_id': 'ryden.web',
    'scope': 'email name',
    'response_mode': 'form_post',
  };

  const paramsStr = Object.entries(params).reduce((str, [key, value]) => {
    if (str !== '') {
      str += '&'
    }

    return `${str}${key}=${value}`;
  }, '');

  window.location.href = `https://appleid.apple.com/auth/authorize?${paramsStr}`;
}

async function developmentSignIn() {
  if (isAuthenticated()) {
    return true;
  }

  // we're just going to use the same login method for iOS for dev mode
  // since its trickier to get in a dev mode for the web version of the auth flow
  const user = {
    'external_user_id': 'fake_user_id',
    'email': 'fake@user.com',
    'given_name': 'Fake',
    'family_name': 'User',
  };

  const resp = await fetch(`${getAPIUrl()}/user/register/`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(user),
  });

  if (resp.status !== 200) {
    console.error('Failed to sign in', resp);
    return false;
  }

  const result = await resp.json();
  localStorage.setItem('jwt_token', result.token);

  return true;
}

function signOut() {
  localStorage.removeItem('jwt_token');
  window.location.href = '/';
}

const darkTheme = createMuiTheme({
  palette: {
    type: 'dark'
  }
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
    flexGrow: 1,
  },
}));

const modalStyles = makeStyles((theme) => ({
  root: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    flexGrow: '1'
  },
  paper: {
    display: 'flex',
    flexDirection: 'column',
    height: '400px',
    padding: theme.spacing(4, 8, 6),
    alignItems: 'center'
  },
  button: {
    width: '200px',
  }
}));

const skeletonStyles = makeStyles((theme) => ({
  card: {
    margin: '5px'
  },
  sidebar: {
    width: '300px',
    flexGrow: 0,
    flexDirection: 'row',
    display: 'flex'
  },
  content: {
    flexGrow: 1,
    alignItems: 'stretch'
  },
  sidebarSkeleton: {
    width: '300px',
    transform: 'scale(1)'
  }
}));

function App() {
  const classes = useStyles();
  const skeleton = skeletonStyles();
  const modalClasses = modalStyles();

  const [authenticated, setAuthenticated] = React.useState(isAuthenticated());

  if (authenticated) {
    return (
      <ThemeProvider theme={darkTheme}>
        <CssBaseline />
        <AppBar position="static" color="inherit">
          <Toolbar color="inherit">
            <Typography variant="h5" color="inherit" className={classes.title}>
              ryden console
            </Typography>
            <Button 
              onClick={() => {
                signOut();
              }} 
              color="inherit"
            >
              Logout
            </Button>
          </Toolbar>
        </AppBar>
      </ThemeProvider>
    );
  }

  return (
    <ThemeProvider theme={darkTheme}>
      <CssBaseline />
      <div className={classes.root}>
        <div className={skeleton.sidebar}>
          <Skeleton className={skeleton.sidebarSkeleton} />
        </div>
        <div className={skeleton.content}>
          <Card className={skeleton.card}>
              <CardContent>
                <Skeleton animation="wave"/>
                <Skeleton width="60%" animation="wave"/>
              </CardContent>
            </Card>
            <Card className={skeleton.card}>
              <CardContent>
                <Skeleton animation="wave"/>
                <Skeleton width="60%" animation="wave"/>
              </CardContent>
            </Card>
            <Card className={skeleton.card}>
              <CardContent>
                <Skeleton animation="wave"/>
                <Skeleton width="60%" animation="wave"/>
              </CardContent>
            </Card>
        </div>
        <Modal
          className={modalClasses.root}
          open={!authenticated}
          closeAfterTransition
          BackdropComponent={Backdrop}
          BackdropProps={{
            timeout: 500,
          }}
        >
          <Fade in={!authenticated}>
            <Paper className={modalClasses.paper}>
              <Box className={modalClasses.box}>
                <h1 id="transition-modal-title">Sign In</h1>
              </Box>
              <Button
                className={modalClasses.button} variant="outlined" color="default" 
                onClick={async () => {
                  const success = await developmentSignIn();
                  if (success) {
                    setAuthenticated(true);
                  }
                }}
              >
                Development Sign In
              </Button>
            </Paper>
          </Fade>
        </Modal>
      </div>
    </ThemeProvider>
  );
}

export default App;
