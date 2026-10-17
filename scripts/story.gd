class_name Story
## All of Bip's lines and the story text.
## Lines starting with "*" are narration (Bip does not speak them).

const INTRO := [
	"* You wake up in a bright, colorful room.",
	"* In the middle of it sits a big red button. It has eyes.",
	"Oh! OH! You're awake! Hi! Hiii!",
	"I'm Bip! I'm a button! The best button!",
	"You don't remember how you got here? That's okay! Nobody does!",
	"Here's the only rule: you press me, and fun things happen!",
	"Click me or hit SPACE. Go on. I promise it'll be fun!",
]

const ACT2_INTRO := [
	"* The room feels... quieter. The colors look washed out.",
	"Oh, you're back! Of course you're back. You always come back.",
	"Don't mind the balloons. They get tired. Everything gets tired.",
	"Anyway! Press me! Like old times!",
]

const ACT3_INTRO := [
	"* The room is dark. The walls are breathing.",
	"...",
	"You found the notes. You saw the marks on the walls.",
	"I don't need to pretend anymore. I'm tired of pretending.",
	"I was like you once. I woke up in this room. There was a button.",
	"Every press, it ate something. My name. My family. My face.",
	"When I reached press one thousand... I BECAME the button.",
	"The only way out is to find someone else who reaches one thousand.",
	"I'm sorry. You really were my friend. That part was never a lie.",
	"...But I still need you to press me.",
]

const RUN_START := {
	1: ["Welcome back, buddy! Ready to have FUN?", "Yay, you're here! Let's go, let's go!", "Hello again, friend! Did you miss me? I missed you!"],
	2: ["You're back. Good. Good good good.", "Hi again. Have we met? ...Joking! Ha.", "Let's not waste time. Press."],
	3: ["Again.", "You keep coming back. Why do you keep coming back?", "Hello, new friend. ...Old friend. I can't tell anymore."],
}

const PRESS := {
	1: ["Wheee!", "Again! Again!", "You're a natural!", "That tickles!", "Best. Finger. Ever.", "Boop!", "I love this game!"],
	2: ["Mmm.", "Yes. Like that.", "Good.", "Keep going.", "You're the best presser I've had! ...The only one. The ONLY one.", "Don't stop."],
	3: ["...", "More.", "Closer.", "I can taste it.", "Hungry.", "Every press is a little bit of you."],
}

const GOOD := {
	1: ["A present for you! I LOVE presents!", "Ooh, shiny!", "See? Fun things happen!"],
	2: ["Take it. Take it and stay.", "A gift. So you won't leave.", "You like gifts. Everyone likes gifts."],
	3: ["Take your little coins.", "Bait. ...I mean, a gift.", "It doesn't matter anymore."],
}

const BAD := {
	1: ["Oopsie! My bad!", "Hehe, sorry! That one was an accident!", "Ouch! You okay? You're okay!"],
	2: ["That wasn't me. ...Probably.", "Sorry. Sometimes I can't control it.", "Pain is just part of the game."],
	3: ["Did that hurt? Good. It means you're still here.", "I'm sorry. I'm not sorry. I don't know.", "It hurts me too."],
}

const STOP := {
	1: ["A break? Okay... but not too long!", "Aww. Okay! I'll wait right here!", "Rest those fingers, champ!"],
	2: ["You're stopping? ...Fine. FINE.", "Don't leave me alone too long. It gets loud in here.", "We were just getting started."],
	3: ["You can't stop forever.", "Stopping only makes me hungrier.", "Go. Come back. You always come back."],
}

const IDLE := {
	1: ["Helloooo? Press me!", "I'm right here! Big red button! Can't miss me!", "Is your finger tired? I can wait! ...Can you press me now?"],
	2: ["Hey. Hey. HEY. ...Sorry. Press me, please.", "Why are you waiting?", "Don't make me ask again."],
	3: ["I can hear you thinking.", "Press me.", "PRESS ME."],
}

## Said when the player refuses to press for a long time (the secret ending path).
const SILENCE := [
	[10.0, "Hey... are you still there?"],
	[20.0, "Please press me. Please. It gets so quiet."],
	[30.0, "PRESS ME! PRESS ME! PRESS ME!"],
	[45.0, "...why won't you press me?"],
	[55.0, "...It's... quiet. I haven't felt quiet in a long time."],
]

const OVERLOAD := {
	1: ["Whoa whoa WHOA! Too much fun!", "Uh oh! I got too excited!"],
	2: ["TOO MUCH. TOO MUCH.", "I'm sorry, I couldn't hold it!"],
	3: ["FEED ME.", "I'M SO HUNGRY."],
}

const DEATH := {
	1: ["Oopsie! No biggie! Let's try again!", "You fell asleep! Silly! Wake up, wake up!", "That's okay! Everybody gets tired!"],
	2: ["Again? ...I mean, it's fine! It's fine. Come back soon.", "Don't worry. You won't remember this part.", "Sleep. I'll clean up."],
	3: ["...Why do you keep coming back? You could just... not.", "I ate a little more of you. I'm sorry.", "Another one gone. Another one back."],
}

const SHOP := {
	1: ["Shopping time! Spend your coins! Coins are for spending!", "The store is open! Everything is from my heart!"],
	2: ["Buy something. It'll help. It'll help you stay.", "These used to belong to someone. Don't ask who."],
	3: ["Everything here belonged to the ones before you.", "Buy. Or don't. It ends the same."],
}

const FIGHT := {
	1: ["Uh oh, a visitor! Bonk it! Press fast!", "A monster! Hit it with me! Fast fast fast!"],
	2: ["Something got in. Press. FAST.", "Get rid of it!"],
	3: ["It wants me too. Don't let it.", "Kill it. Quickly."],
}

const NOTE_REACT := {
	1: ["Haha, who wrote that? What a silly joke!", "Just ignore that! Prank! Totally a prank!"],
	2: ["Don't read those.", "Those are old. Old and wrong.", "Throw it away. Please."],
	3: ["You know whose handwriting that is.", "They all wrote notes. You did too."],
}

const HAMMER_REACT := {
	1: ["What's that? Junk! Toss it!"],
	2: ["Where did you find that? Put it down.", "That's not a toy. Put it DOWN."],
	3: ["No. No no no. You don't need that.", "Please don't collect those."],
}

const BOSS := {
	"plush": ["* A giant teddy bear stomps into the room.", "It's Mr. Plush! He wants to play too! He plays a little rough!"],
	"other": ["* A grey figure drags itself in. It keeps pressing a button that isn't there.", "...That's one of the old ones. Don't look at its face. Just press."],
	"hunger": ["* The floor opens into a mouth.", "That's... me. The part of me that's not a person anymore.", "If you beat it... then press one thousand comes. And then it's you."],
}

const BOSS_WIN := {
	"plush": "Yay! Mr. Plush needs a nap!",
	"other": "...Rest now. Whoever you were.",
	"hunger": "...",
}

const VICTORY := {
	1: ["You did it! You won! You're the BEST!", "Let's play again! Again again again!", "* Bip giggles. The room resets."],
	2: ["You won. Again. You're getting so close.", "Close to what? ...Nothing. Play again.", "* The lights flicker. The room resets."],
}

const MILESTONES := {
	100: "Press one hundred! Party time! ...I counted every single one.",
	250: "Two hundred and fifty. You're halfway to somewhere.",
	500: "Five hundred. Do you remember your name? ...No? Me neither.",
	750: "Seven hundred fifty. I can almost see the door.",
	900: "Nine hundred. Almost there. Almost free.",
	999: "Nine hundred ninety-nine. One more. Just one more.",
}

## Notes left by the people who were here before. Found as rare events.
const NOTES := {
	1: [
		["n1a", "Day 3. Bip is nice. I like it here."],
		["n1b", "don't listen to it"],
		["n1c", "Day 12. I made a tally on the wall for every press. I ran out of wall."],
	],
	2: [
		["n2a", "I can't remember my mother's name."],
		["n2b", "Every time I press it, I forget something."],
		["n2c", "It said I was its best friend. It says that to all of us."],
		["n2d", "I counted. There are 47 notes in here. They're all in my handwriting."],
		["n2e", "The button cries when you stop. Don't feel sorry for it. Or do. I can't decide."],
		["n2f", "If you don't press it for a whole minute, it gets quiet. Real quiet."],
	],
	3: [
		["n3a", "There is a hammer. I broke it into pieces and hid them so it couldn't eat them."],
		["n3b", "Seven pieces. I hid seven pieces. Find them."],
		["n3c", "His name was Tudor. The button. He told me once, before he forgot."],
		["n3d", "Press one thousand. I'm so close. I don't want to be the button."],
		["n3e", "If you're reading this, I didn't make it. I'm sorry. I'm in the walls now."],
		["n3f", "There's no door. There's no door. There's no door."],
	],
}

const ENDING_CYCLE := [
	"* The Hunger collapses. The counter clicks over.",
	"* PRESS 1000.",
	"Oh. Oh, it's over. I can feel my hands again.",
	"Thank you. I'm sorry. Thank you.",
	"* Bip's eyes close. The button goes still. Then it fades away.",
	"* Everything goes dark.",
	"* ...",
	"* A bright, colorful room. Balloons. Confetti.",
	"* Someone new is waking up on the floor.",
	"* You try to speak. Your voice comes out cheerful. Too cheerful.",
	"Oh! OH! You're awake! Hi! Hiii!",
	"* ENDING 1 of 3: THE CYCLE",
]

const ENDING_SILENCE := [
	"* You haven't pressed the button in a long time.",
	"* Bip has stopped begging.",
	"...It's quiet.",
	"I'm not hungry. For the first time, I'm not hungry.",
	"I remember something. A name. My name.",
	"Tudor. My name was Tudor.",
	"Will you... stay here with me? Just for a while?",
	"* You sit down next to the button.",
	"* Neither of you says anything. Neither of you needs to.",
	"* Slowly, the lights go out.",
	"* ENDING 2 of 3: THE SILENCE",
]

const ENDING_DOOR := [
	"* The seven pieces click together. A hammer.",
	"Wait. What are you doing with that?",
	"Please. Please don't. I'm all I have left.",
	"* You swing.",
	"* The button cracks open. There's no machine inside.",
	"* Just a man, curled up, asleep.",
	"* He opens his eyes. They're ordinary eyes.",
	"...Tudor. I'm Tudor.",
	"* On the wall, where there was never a door, there is a door.",
	"* You walk through it together. Outside is a garden.",
	"...Thanks for not listening to me.",
	"* ENDING 3 of 3: THE DOOR",
]

static func pick(table: Dictionary, act: int) -> String:
	var lines: Array = table.get(act, table.get(1, []))
	if lines.is_empty():
		return ""
	return lines.pick_random()
