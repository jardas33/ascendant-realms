extends RefCounted
## What each faction's hero calls out: at the horn that opens a battle, and
## now and then when you order them to march or to strike. Short lines, in
## the voice of the people the faction comes from.

const LINES := {
	"barrosan": {
		"start": ["For the oven and the bull!", "The village stands. So do we.", "Salto remembers. Forward."],
		"move": ["Slow and sure.", "Where the herd goes, we go.", "Mind the pass."],
		"attack": ["The bull charges!", "For the common pasture!", "Break them on the granite!"],
	},
	"lioraen": {
		"start": ["The springs are listening.", "Walk softly. Strike true."],
		"move": ["Through the green.", "The water knows the way."],
		"attack": ["Rise, Mouras, rise!", "Roots and thorns!", "For the Encantadas!"],
	},
	"vorthak": {
		"start": ["Furna burns in us still.", "They drowned us once. Never again."],
		"move": ["Chains up. Move.", "The ash walks."],
		"attack": ["Violet fire!", "Remember Furna!", "Burn it to glass!"],
	},
	"grimtusk": {
		"start": ["No more chains. Only iron.", "The mines are ours now."],
		"move": ["Tusks forward.", "Stomp on."],
		"attack": ["Smash the bronze!", "Iron for iron!", "Break their chains, break their bones!"],
	},
	"sylvan": {
		"start": ["We did not fade. We waited.", "The Court is gathered."],
		"move": ["As the mist moves.", "Unseen, we pass."],
		"attack": ["The Mouras have not forgotten!", "Gold and thread!", "Take them under!"],
	},
	"karak": {
		"start": ["The castro holds. Always.", "Stone remembers every Ascension."],
		"move": ["Step by step, like the hill.", "Slowly. Like stone."],
		"attack": ["The wall walks!", "Grind them down!", "For the hillfort!"],
	},
	"sunspear": {
		"start": ["The seventy-fifth was ours. So is this.", "Bronze and sun, soldiers."],
		"move": ["March in order.", "The legion advances."],
		"attack": ["For the Dominion!", "Shields up, spears down!", "Sun take them!"],
	},
	"wyldkin": {
		"start": ["The moon is full enough.", "Seven sons, one pack."],
		"move": ["Run with me.", "Follow the scent."],
		"attack": ["Hunt!", "The wolves are loose!", "Throat and heel!"],
	},
	"hollow": {
		"start": ["Take the candle. Carry the cross.", "The procession walks tonight."],
		"move": ["By candlelight.", "The road is long for the dead."],
		"attack": ["Join the procession!", "Your candle is lit!", "Walk with us forever!"],
	},
	"frostborn": {
		"start": ["Ring the cowbells!", "Winter comes masked."],
		"move": ["Bells on, lads.", "Dance through the snow."],
		"attack": ["Entrudo takes you!", "Masks and iron!", "Ring them down!"],
	},
}

## A line for this faction and moment, or "" when there is none.
static func pick(race: String, moment: String) -> String:
	var lines: Array = LINES.get(race, {}).get(moment, [])
	if lines.is_empty():
		return ""
	return String(lines[randi() % lines.size()])
