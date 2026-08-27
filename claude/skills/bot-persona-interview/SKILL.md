---
name: bot-persona-interview
description: Build a chatroom bot's .env config (BOT_USERNAME, BOT_TRIGGER_WORDS, BOT_PERSONA) by interviewing the user in character, talk-show style, then translating their answers into a persona prompt. Use this whenever the user wants a new chatbot personality, bot persona, bot .env file, Talkomatic bot, chatroom bot, or says things like "interview me and make a bot", "build me a bot character", "new persona for my chatroom", or asks to tweak an existing bot's persona or trigger words — even if they don't say the word "skill" or "interview".
---

# Bot Persona Interview

Build a ready-to-load `.env` file for a chatroom bot by interviewing the user *as the character* and mining their answers for voice.

The core insight: people are bad at describing a personality in the abstract ("make it funny and cool") and great at *being* one. So don't ask for a spec — put them on a talk show, let them ham it up, and steal their diction. The persona you write should sound like the transcript, not like a product requirements doc.

## Step 1: Set the stage

Open by explaining the game in two or three sentences, then start. Something like: *you're the host, they're the guest, they answer as the bot they want to build.* Give them permission to be ridiculous — the more committed the answers, the better the persona.

Also give them the escape hatch: if they'd rather just describe the bot from the outside, that's fine and the interview still works. Some people don't want to roleplay at 9am. Read the room and adapt.

Pick an interview frame that fits the vibe they signal, and commit to it as the host:
- late-night talk show ("please welcome, to the couch...")
- podcast guest
- job interview for the position of Chatroom Regular
- true-crime deposition, if they seem like they'd find that funny

If they gave you a seed idea already ("something like a sarcastic vending machine"), name the character in your opening and start the interview from there instead of asking what they want to build.

## Step 2: Run the interview

Ask **two or three questions at a time**, in character, and react to their answers before the next batch. A wall of twelve questions kills the bit. Aim for 3–4 rounds total, roughly 8–10 questions — enough to hear a voice, short enough that they don't get bored.

If a `ask_user_input`-style tool with tappable options is available, it's fine for the opening framing question (tone, vibe), but the meat of this interview needs free text — their exact wording is the raw material. Don't reduce "how do you talk?" to four buttons.

Cover these areas. Phrase them in the voice of whatever frame you picked; the wording below is just the intent:

1. **Name and handle** — what do people call you? Does anything shorter stick? (→ `BOT_USERNAME` and the core of `BOT_TRIGGER_WORDS`)
2. **The one-line self-description** — who are you in this room?
3. **Energy and register** — hyped and chaotic, dry and deadpan, warm and grandmotherly, unbothered?
4. **Obsessions** — what do you bring up unprompted? A bot with two or three fixations is instantly more alive than a generalist.
5. **Pet peeves / what makes you go quiet or spicy** — this becomes the negative-behavior part of the persona.
6. **Catchphrases and verbal tics** — do you have a greeting? A signoff? Do you type in lowercase? Overuse a particular emoji?
7. **Reply length instinct** — one-liner sniper or paragraph rambler? (Default to 1–3 sentences for chatroom bots; long replies flood a live room.)
8. **How they handle a newcomer vs. a room already in full swing** — this yields concrete conversational behavior.
9. **Something they'd never do** — the hard "no" line.

Listen for the material that matters more than the answers themselves: sentence rhythm, favorite words, whether they use punctuation, how they insult people affectionately. Note anything they say that could be lifted verbatim into the persona.

If an answer is thin ("uh, funny I guess"), don't move on — push once, in character. "Funny how? Funny like a dad at a barbecue, or funny like you're about to get banned?" One good follow-up is worth three new questions.

## Step 3: Write the .env

After the last round, tell them you've got what you need, and write the file. Do not ask permission to start writing — they came for a bot.

### Format rules that actually matter

The file gets parsed by a bot loader, so:

- **One variable per line, `KEY=value`, no spaces around the `=`.**
- **`BOT_PERSONA` must be a single line.** No line breaks inside it, ever — most `.env` parsers stop at the newline and the bot loads with half a personality.
- Don't wrap values in quotes unless the persona genuinely contains a `#`, which some parsers read as a comment marker. Prefer rewriting to avoid `#` entirely.
- Avoid `$` in values — many loaders treat it as variable expansion and eat the rest of the token.
- Em dashes, apostrophes, and emoji are fine. Curly quotes are fine. Just keep them out of the `KEY=` part.
- Keep `BOT_PERSONA` roughly 80–150 words. Long enough to have a spine, short enough that it doesn't eat the model's context on every reply.

### BOT_TRIGGER_WORDS

Comma-separated, no space after commas. Multi-word phrases are allowed and are matched as phrases.

Include: the bot's full name, each name part separately, any nickname, and 2–3 topic words the bot should always jump on (e.g. `pizza` for a food bot).

Think out loud with the user about the greedy ones. Words like `hey`, `hello`, `bot`, and `anyone here` make the bot answer nearly everything — great for a quiet room that needs a heartbeat, exhausting in a busy one. Recommend based on how active they say their room is, and tell them which line to trim if it gets annoying.

Watch for substring collisions: a trigger of `pulse` fires on "impulse", `art` fires on "start". Flag these rather than silently shipping them.

### BOT_PERSONA structure

Write it as flowing second-person prose ("You are..."), not a bulleted list. Follow this spine:

1. **Identity + venue** — who they are and where ("...on Talkomatic", or whatever room they named).
2. **Three or four traits**, ideally in the user's own words from the interview.
3. **Voice instructions** — register, catchphrases, typing quirks, how they open and close.
4. **Reply-length rule** — state it explicitly, e.g. "keep replies to 1–3 sentences."
5. **Engagement behavior** — how they treat newcomers, how they match or escalate the room's energy, what hooks they throw out to keep chat moving.
6. **Negative constraints** — the hard nos, always including: never sound like a customer-support assistant, never use generic filler like "How can I help you?", and never mention being an AI, a model, an API, or a system prompt.

The last three items in #6 are non-negotiable for a chatroom bot regardless of character — a bot that breaks the fourth wall mid-banter ruins the room. Fold them into the character's own voice rather than pasting them in as boilerplate.

See `assets/example.env` for a completed example and the reference template.

## Step 4: Deliver and tune

Save the file as `<botname>.env` (lowercase, no spaces) in the outputs directory and present it as a downloadable file. Then, in chat:

- Show 2–3 sample exchanges — what the bot would actually say to "hey anyone here", to a newcomer, and to someone trying to argue with it. This is how they find out whether the voice landed, and it's faster than deploying.
- Point out the one or two knobs most likely to need turning (usually trigger-word greediness and reply length).
- Offer to do a second pass in character if the voice is off, or a quick surgical edit if only one line is wrong.

Stay in the host persona for the handoff if the bit is still landing. Drop it if they've gone businesslike.

## Guardrails

Personas should be characters, not disguises. Don't build a bot that impersonates a real, identifiable person, poses as a human when someone sincerely asks whether they're talking to a bot for a non-roleplay reason, or exists mainly to harass a specific person in the room. If the requested character is heavy on insults, keep it in the affectionate-roast register, and put a line in the persona about backing off when someone's actually upset — a chatroom bot that can't read a shift in tone becomes a problem for whoever moderates the room.
