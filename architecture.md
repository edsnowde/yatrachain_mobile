# YatraChain - Smart Transportation App Architecture

## Overview
YatraChain is a Kerala-inspired smart transportation app that gamifies urban travel with AI assistance, live trip tracking, and crowdsourced data.

## Core Features
1. **Trip Detection & Smart Diary** - Automatic trip logging with manual override
2. **AI Chatbot (YatraBot)** - Smart route suggestions and travel assistance
3. **Live Map with Crowdsourcing** - Real-time overcrowding and delay flags
4. **Gamification System** - Badges, stats, and rewards for eco-friendly travel
5. **Malayalam/English Toggle** - Local language support

## App Structure

### Main Pages (4 tabs)
1. **Home Dashboard** - Greeting, stats, quick actions, live trip card
2. **Smart Diary** - Trip history with expandable cards
3. **Live Map** - Interactive map with crowdsourced data
4. **Chatbot (YatraBot)** - AI assistant with quick replies
5. **Profile** - Stats, badges, settings

### Additional Screens
- **Splash Screen** - YatraChain logo animation
- **Onboarding** - 3-slide introduction with problem/promise/consent
- **Trip Detail Modal** - Expandable trip information
- **Nudge Modal** - Post-trip data collection
- **Reward Popup** - Badge unlock celebrations

## Technical Implementation
- **State Management**: Provider pattern for simplicity
- **Local Storage**: SharedPreferences for user data and trip history
- **Mock Data**: Realistic sample trips and chatbot responses
- **Animations**: Hero animations, page transitions, Lottie animations
- **UI Components**: Material 3 with custom Kerala-inspired colors

## Color Scheme
- Primary: Deep Blue (#1A73E8) - trustworthy transport feel
- Secondary: Kerala Green (#2E7D32) - local flavor
- Background: Light grey (#F5F5F5) / Dark (#121212)
- Accent colors for different transport modes

## Demo Features
- Pre-loaded trip data for instant demo
- Mock AI responses for chatbot
- Fake badge unlock animations
- Dark mode toggle
- Malayalam text samples