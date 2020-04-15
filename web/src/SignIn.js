import React from 'react';
import Dialog from '@material-ui/core/Dialog';
import Backdrop from '@material-ui/core/Backdrop';
import Fade from '@material-ui/core/Fade';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import Skeleton from '@material-ui/lab/Skeleton';
import Paper from '@material-ui/core/Paper';
import Box from '@material-ui/core/Box';
import Button from '@material-ui/core/Button';
import { makeStyles } from '@material-ui/core/styles';

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
    padding: theme.spacing(6, 6, 6),
    alignItems: 'center'
  },
  button: {
    width: '200px',
  }
}));

const skeletonStyles = makeStyles((theme) => ({
  root: {
    display: 'flex',
    height: '100%',
    flexDirection: 'row',
    alignItems: 'stretch',
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
  card: {
    margin: '5px'
  },
  sidebarSkeleton: {
    width: '300px',
    transform: 'scale(1)'
  }
}));

function SignIn({ onAuthenticate }) {
  const skeleton = skeletonStyles();
  const modalClasses = modalStyles();

  return (
    <div className={skeleton.root}>
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
          <Card className={skeleton.card}>
            <CardContent>
              <Skeleton animation="wave"/>
              <Skeleton width="60%" animation="wave"/>
            </CardContent>
          </Card>
      </div>
      <Dialog
        className={modalClasses.root}
        open={true}
        closeAfterTransition
        BackdropComponent={Backdrop}
        BackdropProps={{
          timeout: 500,
        }}
      >
        <Fade in={true}>
          <Paper className={modalClasses.paper}>
            <Box className={modalClasses.box}>
              <h1 id="transition-modal-title">Sign In</h1>
            </Box>
            <Button
              className={modalClasses.button} variant="outlined" color="default" 
              onClick={onAuthenticate}
            >
              Development Sign In
            </Button>
          </Paper>
        </Fade>
      </Dialog>
    </div>
  );
}

export default SignIn;
