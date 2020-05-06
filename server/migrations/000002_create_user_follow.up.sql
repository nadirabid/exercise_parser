BEGIN;

-- UserFollow ----------------------------------------------

CREATE TABLE IF NOT EXISTS user_follows (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    user_id integer REFERENCES users(id) ON DELETE CASCADE,
    follow_id integer REFERENCES user(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_user_id_and_follow_id ON user_follows(user_id, follow_id);

COMMIT;
