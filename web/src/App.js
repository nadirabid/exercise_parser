import React from 'react';
import CssBaseline from '@material-ui/core/CssBaseline';
import { ThemeProvider } from '@material-ui/core/styles';

import SignIn from './SignIn';
import Console from './Console';
import * as auth from './auth';
import { darkTheme } from './globals';

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
        onAuthenticated={() => setAuthenticated(true)}
      />
    </ThemeProvider>
  );
}

export default App;
