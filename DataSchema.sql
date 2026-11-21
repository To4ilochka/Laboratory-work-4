CREATE TABLE users (
    user_id INTEGER NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email_addr VARCHAR(120) NOT NULL UNIQUE,
    PRIMARY KEY (user_id),
    CHECK (CHAR_LENGTH(full_name) >= 2),
    CHECK (email_addr ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TABLE students (
    student_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL UNIQUE,
    group_code VARCHAR(10) NOT NULL,
    PRIMARY KEY (student_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    CHECK (group_code ~ '^[A-Z]{2}-[0-9]{3}$')
);

CREATE TABLE reference_schemas (
    schema_id INTEGER NOT NULL,
    schema_code VARCHAR(10) NOT NULL UNIQUE,
    schema_name VARCHAR(120) NOT NULL,
    cards_total SMALLINT NOT NULL,
    PRIMARY KEY (schema_id),
    CHECK (schema_code ~ '^DBMS-[0-9]{2}$'),
    CHECK (CHAR_LENGTH(schema_name) >= 3),
    CHECK (cards_total BETWEEN 1 AND 6)
);

CREATE TABLE component_cards (
    card_id INTEGER NOT NULL,
    schema_id INTEGER NOT NULL,
    component_name VARCHAR(60) NOT NULL,
    marker_code VARCHAR(10) NOT NULL UNIQUE,
    expected_seq SMALLINT NOT NULL,
    PRIMARY KEY (card_id),
    FOREIGN KEY (schema_id) REFERENCES reference_schemas (schema_id),
    CHECK (CHAR_LENGTH(component_name) >= 3),
    CHECK (marker_code ~ '^AR-[0-9]{2}$'),
    CHECK (expected_seq BETWEEN 1 AND 6)
);

CREATE TABLE attempts (
    attempt_id INTEGER NOT NULL,
    student_id INTEGER NOT NULL,
    schema_id INTEGER NOT NULL,
    attempt_date TIMESTAMP NOT NULL,
    correct_tally SMALLINT NOT NULL,
    attempt_status VARCHAR(20) NOT NULL,
    PRIMARY KEY (attempt_id),
    FOREIGN KEY (student_id) REFERENCES students (student_id),
    FOREIGN KEY (schema_id) REFERENCES reference_schemas (schema_id),
    CHECK (correct_tally BETWEEN 0 AND 6),
    CHECK (attempt_status IN ('passed', 'partial', 'failed'))
);

CREATE TABLE placements (
    placement_id INTEGER NOT NULL,
    attempt_id INTEGER NOT NULL,
    card_id INTEGER NOT NULL,
    position_x_num REAL NOT NULL,
    position_y_num REAL NOT NULL,
    orientation_num REAL NOT NULL,
    detected_seq SMALLINT NOT NULL,
    placement_status VARCHAR(20) NOT NULL,
    PRIMARY KEY (placement_id),
    FOREIGN KEY (attempt_id) REFERENCES attempts (attempt_id),
    FOREIGN KEY (card_id) REFERENCES component_cards (card_id),
    CHECK (position_x_num >= 0),
    CHECK (position_y_num >= 0),
    CHECK (orientation_num >= 0 AND orientation_num < 360),
    CHECK (detected_seq BETWEEN 0 AND 6),
    CHECK (placement_status IN ('correct', 'wrong_position', 'not_detected'))
);

CREATE TABLE mismatches (
    mismatch_id INTEGER NOT NULL,
    attempt_id INTEGER NOT NULL,
    card_id INTEGER NOT NULL,
    mismatch_status VARCHAR(20) NOT NULL,
    explanation VARCHAR(255) NOT NULL,
    PRIMARY KEY (mismatch_id),
    FOREIGN KEY (attempt_id) REFERENCES attempts (attempt_id),
    FOREIGN KEY (card_id) REFERENCES component_cards (card_id),
    CHECK (mismatch_status IN ('order_mismatch', 'missing_card', 'link_error')),
    CHECK (CHAR_LENGTH(explanation) >= 5)
);
