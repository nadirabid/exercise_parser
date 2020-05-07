BEGIN;

-- UserFollow ----------------------------------------------

CREATE TABLE IF NOT EXISTS user_subscriptions (
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    subscriber_id integer REFERENCES users(id) ON DELETE CASCADE,
    subscribed_to_id integer REFERENCES users(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_subscriber_id_and_subscribed_to_id ON subscription(subscriber_id, subscribed_to_id);

COMMIT;
