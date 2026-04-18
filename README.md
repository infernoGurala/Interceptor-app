# Interceptor-app

> **A wise sorting system that auto-sorts learning content based on each user's unique way of learning.**

Interceptor is an intelligent word-learning app powered by **spaced repetition** and **systematic memory recognition**. Unlike ordinary flashcard apps, Interceptor decides _for you_ what words to review, when to review them, and how to test you — so no word is ever ignored or abandoned.

---

## Table of Contents

- [Overview](#overview)
- [Core Features](#core-features)
- [How It Works](#how-it-works)
  - [Learn Phase](#learn-phase)
  - [Test Phase](#test-phase)
- [Screens](#screens)
- [Architecture](#architecture)
- [Getting Started](#getting-started)

---

## Overview

Interceptor is not a simple card-deck app. It is an **adaptive review system** that:

- Collects words you encounter in books, articles, passages, or anything you read.
- Learns your memory patterns and schedules reviews at the optimal moment.
- Automatically selects which words you will study today — you never pick the deck yourself.
- Ensures every word you save eventually reaches long-term memory through a structured Learn → Test pipeline.

---

## Core Features

| # | Feature | Description |
|---|---------|-------------|
| 1 | **Spaced Repetition** | Words are scheduled for review at scientifically timed intervals to maximize retention. |
| 2 | **Add / Remove Words** | Users manually add words and their meanings from anything they read. |
| 3 | **Storage Interceptor** | Persistent storage layer that keeps all words, progress, and review history safe. |
| 4 | **System Interceptor** | The intelligent engine that sorts, groups, and schedules words without any user intervention. |

---

## How It Works

### The System Decides — Not the User

The **System Interceptor** engine sits at the core of the app. It:

1. Groups words into internal collections automatically.
2. Chooses which words appear in today's session based on review history and learning thresholds.
3. Moves words between the **Learn** queue and the **Test** queue at the right time.

### Learn Phase

Before a word can be tested, the user must **learn** it first.

- The word and its meaning are presented to the user.
- The user must encounter the word a minimum number of times (the **learning threshold**) before it is promoted to the Test phase.
- The threshold ensures shallow exposure doesn't count as mastery.

### Test Phase

Once a word has been learned the required number of times, it is moved to **Test**.

- The user is quizzed on the word without seeing the meaning upfront.
- Performance on tests feeds back into the spaced-repetition schedule.
- Words that are answered incorrectly are rescheduled for sooner review; well-known words are spaced further apart.

---

## Screens

| Screen | Description |
|--------|-------------|
| **Origin Screen** (`origin_screen_interceptor`) | The landing / home screen that greets the user and provides navigation into Learn and Test sessions. |
| **Profile Screen** (`profile_screen_interceptor`) | Displays the user's personal word list, progress statistics, and review history. |

---

## Architecture

```
┌─────────────────────────────────────────────┐
│                  User Input                  │
│  (words & meanings from books / articles)   │
└───────────────────┬─────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│            Storage Interceptor               │
│   Persists words, meanings & review data     │
└───────────────────┬─────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│            System Interceptor                │
│  • Sorts & groups words automatically        │
│  • Applies spaced-repetition algorithm       │
│  • Tracks learn threshold per word           │
│  • Promotes words: Learn ──► Test            │
└────────────┬─────────────────┬──────────────┘
             │                 │
             ▼                 ▼
      ┌──────────┐      ┌──────────┐
      │  Learn   │      │   Test   │
      │  Queue   │      │  Queue   │
      └──────────┘      └──────────┘
```

---

## Getting Started

1. **Add a word** — Whenever you come across an unfamiliar word (in a book, article, or any passage), open Interceptor and add the word along with its meaning.
2. **Learn** — The system schedules learning sessions. Go through the Learn queue until you hit the threshold for each word.
3. **Test** — Once a word graduates from Learn, it appears in your Test queue. Answer the prompts to reinforce your memory.
4. **Let the system work** — You never need to pick a deck or a category. Interceptor keeps track of everything and surfaces the right words at the right time.

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## License

This project is licensed under the terms found in the repository root.