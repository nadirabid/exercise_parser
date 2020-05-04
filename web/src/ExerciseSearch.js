import React, { useEffect, useState, useRef } from 'react';

import Autocomplete from '@material-ui/lab/Autocomplete';
import TextField from '@material-ui/core/TextField';

import * as auth from './auth';

async function getAPIExerciseSearch(exerciseQuery) {
  const result = await fetch(`${auth.getAPIUrl()}/api/exercise/search?exerciseQuery=${exerciseQuery}`, {
    headers: {
      'Authorization': auth.getAuthHeader(),
    },
  });

  if (result.status !== 200) {
    console.error('Failed to get exercise search results: ', result);
    return false;
  }

  const resp = await result.json();

  return resp;
}

function useRefState(initialValue) {
  const [state, setState] = useState(initialValue);
  const stateRef = useRef(state);
  useEffect(
    () => { stateRef.current = state },
    [state]
  );
  return [state, stateRef, setState];
}

function ExerciseSearch({ onSelect = () => {} }) {
  const [options, setOptions] = useState([]);
  const [input, setInput] = useState('');
  const [counter, counterRef, setCounter] = useRefState(0);
  
  useEffect(() => {
    if (input) {
      getAPIExerciseSearch(input).then((result) => {
        setCounter(counterRef + 1);
        if (counter + 1 < counterRef.value) {
          return;
        }

        setOptions(result.results);
      });
    }
  }, [input]);

  return (
    <Autocomplete
      options={options}
      getOptionLabel={(option) => option.exercise_dictionary_name}
      style={{ width: 300 }}
      filterOptions={(options) => options}
      onChange={(_, v) => onSelect(v)}
      renderInput={(params) => {
        return (
          <TextField
            onChange={(e) => setInput(e.target.value)}
            {...params} label="Exercise Name" variant="outlined" fullWidth
          />
        );
      }}
    />
  );
}

export default ExerciseSearch;