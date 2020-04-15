export function getAPIUrl() {
  const tls = process.env.REACT_APP_TLS;
  const domain = process.env.REACT_APP_API_URL;
  if (tls === 'enabled') {
    return `https://${domain}`;
  }
  
  return `http://${domain}`;
}

export function isAuthenticated() {
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

export function isAuthEnabled() {
  if (process.env.REACT_APP_AUTH === 'disabled') {
    return false;
  }

  return true;
}

export function signInWithApple() {
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

export async function developmentSignIn() {
  if (isAuthenticated()) {
    return true;
  }

  // we're just going to use the same login method for iOS for dev mode
  // since its trickier to get in a dev mode for the web version of the auth flow
  const user = {
    'external_user_id': 'fake.user.id',
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

export function signOut() {
  localStorage.removeItem('jwt_token');
  window.location.href = '/';
}