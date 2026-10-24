-- Facts the bot is allowed to state. One row per fact.
-- The owner edits a row; the workflow is never touched.

CREATE TABLE IF NOT EXISTS business_info (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

INSERT INTO business_info (key, value) VALUES
    ('working_hours',  'Mon-Sat 10:00-19:00, closed on Sunday'),
    ('delivery',       'Same-day delivery inside the city, 5 AZN. Free over 100 AZN.'),
    ('return_policy',  'Unopened items can be returned within 14 days with the receipt.'),
    ('payment',        'Cash, card on delivery, and bank transfer.'),
    ('address',        'REPLACE ME with the real address'),
    ('contact',        'REPLACE ME with the real phone number')
ON CONFLICT (key) DO NOTHING;
