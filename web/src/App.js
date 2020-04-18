import React from 'react';
import CssBaseline from '@material-ui/core/CssBaseline';
import { createMuiTheme, ThemeProvider } from '@material-ui/core/styles';

import SignIn from './SignIn';
import Console from './Console';
import * as auth from './auth';

const darkTheme = createMuiTheme({
  palette: {
    type: 'dark'
  }
});

function App() {
  const [authenticated, setAuthenticated] = React.useState(auth.isAuthenticated());

  if (authenticated) {
    return (
      <ThemeProvider theme={darkTheme}>
        <CssBaseline />
        <Console />
      </ThemeProvider>
    );
  }

  return (
    <ThemeProvider theme={darkTheme}>
      <CssBaseline />
      <SignIn 
        onAuthenticate={async () => {
          const success = await auth.developmentSignIn();
          if (success) {
            setAuthenticated(true);
          }
        }}
      />
    </ThemeProvider>
  );
}

export default App;
