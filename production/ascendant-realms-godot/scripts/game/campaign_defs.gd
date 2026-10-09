extends RefCounted

## The Saga of the Seventy-Seventh Ascension: five Acts of battles with
## side roads, one branching choice and three endings. The story source is
## docs/lore/ASCENDANT_REALMS_SAGA.md. Each chapter:
##   id, act, title, map, opponents [{race, difficulty}], difficulty label,
##   side (optional road), jar (holds a jar of Wine of the Dead),
##   unlocks [ids], branch ("break"/"seize"), briefing (chronicle page),
##   opening (the first line spoken in battle), taunts [3 min, 8 min],
##   victory (the chronicle after winning).

const ACTS := [
	{"title": "Act I: Ashes over Salto", "subtitle": "The Vorthak raid. The Jardas rises. Nothing is what it seems."},
	{"title": "Act II: The Drowned Villages", "subtitle": "The water rises in the valleys. The Mouras wake. The Dominion arrives."},
	{"title": "Act III: Wine of the Dead", "subtitle": "The truth. The dead. The mother."},
	{"title": "Act IV: The Rabagão Wall", "subtitle": "War against the Dominion, and the choice that splits the world."},
	{"title": "Act V: The Seventy-Seventh Ascension", "subtitle": "The Lume wakes fully, and it wants to become a realm of its own."},
]

const JARS_TOTAL := 7

const CHAPTERS := [
	# ------------------------------------------------------------------ ACT I
	{"id": "1-1", "act": 0, "title": "The Spring of Seven Mouths", "map": "salto_valley",
		"opponents": [{"race": "vorthak", "difficulty": "easy"}], "difficulty": "Easy", "unlocks": ["1-2"],
		"briefing": "Salto, on the night of the Ascension. The Vorthak came over the pass with violet fire and chains, and you fell at the Spring of Seven Mouths with a raider's blade in your side.\n\nThen the spring blazed. You stood up with fire in your eyes, and the Lume, the living memory of the highlands, burned in your hands.\n\nThe village calls you Jardas now. Avó Brites calls you nothing at all; she only watches. Drive the raiders out of Salto before dawn.\n\nBeyond the walls the old veins of the valley still run with gold and grain. Raise a mine on one, send the village in to work it, and Salto will feed your war.",
		"opening": "The spring chose you. Now show the raiders what that means.",
		"taunts": ["Malrec: \"A farmhand? The Lume chose a farmhand?\"", "Malrec: \"Keep burning, Jardas. I know how this ends.\""],
		"victory": "The raiders fled up the pass. By the spring, your grandmother stood very still, staring at the water where your reflection should have been."},
	{"id": "1-2", "act": 0, "title": "The Burning Oven", "map": "salto_lower_quarter",
		"opponents": [{"race": "vorthak", "difficulty": "easy"}], "difficulty": "Easy", "unlocks": ["1-3", "1-S1"],
		"briefing": "The raiders did not leave. They took the lower quarter and fired the communal oven, the one every family in Salto has baked in for three hundred years.\n\nThe elders say a village is only as strong as what it shares. Every loaf baked in that oven fed the Lume. Put the fire out, and take back the square.",
		"opening": "Save the oven. Save what we share.",
		"taunts": ["A thrall: \"The master says burn the bread. Burn what they remember.\"", "Malrec: \"Ovens can be rebuilt. Memories cannot. Ask me how I know.\""],
		"victory": "The oven survived, cracked and black. That night the whole village baked in it anyway, and the Lume in your chest burned a little warmer."},
	{"id": "1-S1", "act": 0, "title": "The Wolf-Trap Walls", "map": "fojo", "side": true, "jar": true,
		"opponents": [{"race": "vorthak", "difficulty": "normal"}], "difficulty": "Normal", "unlocks": [],
		"briefing": "In the hills above Salto stand the fojos, stone-walled funnels where your ancestors drove wolves to their deaths. Tonight the Vorthak's gloom hounds have trapped a Wolfveil pack in one.\n\nThe old men say leave them. Wolves are wolves. But the pack is howling your name. How do they know your name?",
		"opening": "The wolves fall silent as you pass. They never do that.",
		"taunts": ["A hound-master: \"The wolves are ours. Everything the moon touches is ours.\"", "A wolf howls, and somewhere a man's voice answers in the same key."],
		"victory": "The pack slipped into the dark. At dawn, a clay jar sealed with pitch sat on the trap's wall, still cold from the earth. It smelled of wine and old smoke. Avó Brites went white when she saw it."},
	{"id": "1-3", "act": 0, "title": "Garrano Run", "map": "garrano_pass",
		"opponents": [{"race": "vorthak", "difficulty": "normal"}], "difficulty": "Normal", "unlocks": ["1-4"],
		"briefing": "Malrec's outriders are racing for the pass with what they stole: the parish records, every name in Salto for four hundred years.\n\nThe wild garranos of the high pasture run with you. Catch the raiders before they cross.",
		"opening": "They stole our names. Ride.",
		"taunts": ["An outrider: \"Why do you care about old paper, Jardas?\"", "Malrec: \"Names are Lume. I need every one I can find.\""],
		"victory": "You recovered the records, but one page had been torn out. It was the page for the year you were born."},
	{"id": "1-4", "act": 0, "title": "Ashfen Mire", "map": "ashfen_mire",
		"opponents": [{"race": "vorthak", "difficulty": "normal"}], "difficulty": "Normal", "unlocks": ["1-5", "1-S2"],
		"briefing": "The ash trail leads into Ashfen, a bog where nothing should burn. Yet the reeds glow violet at night, and the peat smokes underwater.\n\nThis is where drowned Lume goes: it rots into ash-glass. The Vorthak harvest it here. Burn their harvest.",
		"opening": "The water here is warm. Water should not be warm.",
		"taunts": ["Malrec: \"You see it now? This is what drowned memory becomes.\"", "A Veil Warlock: \"We were a village once. Ask the Dominion what happened.\""],
		"victory": "Among the burned ash-glass you found a child's shoe, fused into the glass. The Vorthak were not born monsters."},
	{"id": "1-S2", "survive": 360, "act": 0, "title": "The Night of the Witches", "map": "montalto_witches_night", "side": true, "jar": true,
		"opponents": [{"race": "vorthak", "difficulty": "normal"}], "difficulty": "Normal", "unlocks": [],
		"briefing": "It is Friday the thirteenth, the Night of the Witches at Montalto castle. The whole valley gathers to burn the queimada and speak the esconjuro, the old charm against the dark.\n\nThe Cabal wants the charm unspoken. Keep the fire lit until Avó Brites finishes the words.",
		"opening": "Owls and toads and witches... keep the fire burning.",
		"taunts": ["A warlock: \"Old words, old woman. Old words cannot stop us.\"", "Avó Brites: \"Hold them, child. I am nearly done. Do not look into the bowl.\""],
		"victory": "The esconjuro was spoken. When the blue flame rose from the bowl, every face around it was reflected in the brandy but yours. At the bottom of the bowl lay a second clay jar."},
	{"id": "1-5", "act": 0, "title": "Tourém Crossing", "map": "tourem_crossing",
		"opponents": [{"race": "vorthak", "difficulty": "normal"}, {"race": "sunspear", "difficulty": "easy"}], "difficulty": "Normal", "unlocks": ["1-6", "1-S3"],
		"briefing": "Tourém, the smugglers' village on the border, has sold your location to both sides: to the Vorthak, and to strangers in bronze who pay in southern gold.\n\nHold the bridge. And find out who the men in bronze are.",
		"opening": "Two armies. One bridge. Someone in Tourém got very rich today.",
		"taunts": ["A bronze-helmed captain: \"By order of the Sun Regent, surrender the Lume.\"", "Malrec: \"The Dominion is here? Then we are all out of time.\""],
		"victory": "The bronze soldiers carried Dominion survey maps. Every highland valley was marked with a line and a single word: DROWN."},
	{"id": "1-S3", "act": 0, "title": "The People's Bull", "map": "garrano_pass", "side": true,
		"opponents": [{"race": "vorthak", "difficulty": "normal"}], "difficulty": "Normal", "unlocks": [],
		"briefing": "Every village in Barroso keeps a boi do povo, a bull that belongs to everyone and fights for the village's honor at the Chega. Last night the raiders took Salto's bull, Trovão, and drove him toward the pass.\n\nNo one in Salto will sleep until he is home. Bring him back.",
		"opening": "Trovão is ours. All of ours.",
		"taunts": ["A raider: \"A bull? You march an army for a bull?\"", "Somewhere ahead, a great bellow shakes the pines."],
		"victory": "Trovão came home through the square with the whole village walking beside him. Avó Brites put a ribbon on his horns and said nothing about the scar on his flank, shaped like a violet flame."},
	{"id": "1-6", "act": 0, "title": "Malrec's Pyre", "map": "malrecs_pyre",
		"opponents": [{"race": "vorthak", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": ["2-1"],
		"briefing": "The Vorthak camp burns in the Emberfall rift: ash-glass forges, chained thralls, and at the center, Malrec's pyre.\n\nBreak the camp. Face the Ash-Masked. End the raids on Salto for good.",
		"opening": "This ends tonight, Malrec.",
		"taunts": ["Malrec: \"I was a Jardas once, you know. Seventy-seven years ago.\"", "Malrec: \"You have your mother's stubbornness. Leonor never listened either.\""],
		"victory": "Beaten, Malrec took off his mask. Half his face was violet glass. The other half was an old highland farmer's. \"Ask your grandmother why the spring never shows your face,\" he said, and the ash took him away."},
	# ----------------------------------------------------------------- ACT II
	{"id": "2-1", "act": 1, "title": "The Dam at Salto", "map": "rabagao_gorge",
		"opponents": [{"race": "sunspear", "difficulty": "normal"}], "difficulty": "Normal", "unlocks": ["2-2"],
		"briefing": "Dominion engineers are surveying the river gorge below Salto. Stakes and ropes mark where the water will rise, right up to the church door.\n\nThe Aurean Dominion won the last Ascension war and never left. Scatter their surveyors before the stakes become a wall.\n\nThe Dominion wants the gorge for its mines. Every vein you hold is one their engineers cannot drown.",
		"opening": "They are measuring our valley for a grave.",
		"taunts": ["An engineer: \"Nothing personal. The water has to go somewhere.\"", "A centurion: \"The Regent builds for a thousand years. You will not stop it.\""],
		"victory": "The surveyors fled, but their plans were already sealed and sent south. The dam would be built. The question was where the water would go."},
	{"id": "2-2", "act": 1, "title": "Grove of Seven Fountains", "map": "seven_fountains",
		"opponents": [{"race": "lioraen", "difficulty": "normal"}], "difficulty": "Normal", "unlocks": ["2-3", "2-S3"],
		"briefing": "The Lioraen, the fairy-folk of the springs, have come out of the groves in force. They attack on sight: they believe you are a thief carrying stolen Lume.\n\nYou need them as allies. First, they need to lose.",
		"opening": "They think I stole it. Maybe I did.",
		"taunts": ["Ilduara: \"Give it back. It was never yours to carry.\"", "Ilduara: \"You smell of the spring. Of cold water and old stone.\""],
		"victory": "Ilduara lowered her blade. \"You did not steal it,\" she said slowly. \"It chose you. That is much worse.\""},
	{"id": "2-S3", "act": 1, "title": "The Smugglers' Path", "map": "tourem_crossing", "side": true,
		"opponents": [{"race": "sunspear", "difficulty": "normal"}, {"race": "grimtusk", "difficulty": "easy"}], "difficulty": "Normal", "unlocks": [],
		"briefing": "For three hundred years the contrabandistas of Tourém carried coffee, cloth and news across the border by night. Now the Dominion has closed the paths, and the smugglers' last cargo is people: the families of the drowned villages.\n\nClear the path before the patrols find them.",
		"opening": "Nobody on this path has a name tonight. Keep it that way.",
		"taunts": ["A Dominion officer: \"Smuggling is theft from the Regent.\"", "An old smuggler: \"The mountain has more paths than the Regent has soldiers.\""],
		"victory": "The last family crossed at dawn. The old smuggler pressed a worn tin compass into your hand. 'It always points home,' he said. 'Mine is gone. Yours is not.'"},
	{"id": "2-3", "act": 1, "title": "Where the Bread Was Left", "map": "bread_fountain",
		"opponents": [{"race": "sunspear", "difficulty": "normal"}], "difficulty": "Normal", "unlocks": ["2-4", "2-S1"],
		"briefing": "At the fountain where highland women still leave bread for the Mouras, Dominion soldiers are pouring stone into the spring.\n\nFight beside the Lioraen. And ask them, at last, what they really are.",
		"opening": "Ilduara: \"Fight with us, Jardas. We will tell you everything.\"",
		"taunts": ["A Dominion captain: \"Fairy stories. We are building a real world.\"", "Ilduara: \"They sealed the spring at Ledo last spring. My sister is still inside.\""],
		"victory": "The spring ran clear. Ilduara told you the truth: the Lioraen are the Mouras Encantadas of the legends, guardians sworn to the First Oath. They guarded the Lume, and the villages would remember them. The villages forgot, and the Mouras are fading into trees."},
	{"id": "2-S1", "act": 1, "title": "The Candle Road", "map": "candle_road", "side": true, "jar": true,
		"opponents": [{"race": "hollow", "difficulty": "normal"}], "difficulty": "Normal", "unlocks": [],
		"briefing": "At midnight, on the road above the marsh, a procession of candles: the Compaña, the dead who walk until someone remembers their names. A living woman at the front carries a cross.\n\nThey block the only road to the lower fountains. Break through.",
		"opening": "Do not take the candle, whatever they offer. Everyone knows that.",
		"taunts": ["The procession sings, and none of the voices are loud enough to hear.", "The Cross-Bearer: \"...not yet. Not yet, my love.\""],
		"victory": "The Compaña parted around you without a single blade touching you, as if you were one of them. Where the Cross-Bearer had stood, a third clay jar waited in the mud."},
	{"id": "2-4", "act": 1, "title": "Furna Below the Water", "map": "furna_reservoir",
		"opponents": [{"race": "vorthak", "difficulty": "normal"}, {"race": "sunspear", "difficulty": "normal"}], "difficulty": "Hard", "unlocks": ["2-5"],
		"briefing": "The summer has been dry, and the reservoir has fallen. The roofs of Furna, a village drowned by the Dominion's oldest dam seventy-seven years ago, have come up out of the water.\n\nThe Vorthak come here to mourn. The Dominion comes to stop them. You come for answers.",
		"opening": "Church bells under the water. Someone is still ringing them.",
		"taunts": ["A Vorthak thrall: \"This was my grandmother's house.\"", "A Dominion officer: \"Burn the Vorthak shrines. No martyrs.\""],
		"victory": "In the drowned church you found the parish roll of Furna. The last Jardas of Furna was named Malrique. Below it, in a child's hand, his little sister had written her own name: Brites."},
	{"id": "2-5", "act": 1, "title": "The Regent's Envoy", "map": "envoys_field",
		"opponents": [{"race": "sunspear", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": ["2-6", "2-S2"],
		"briefing": "Sun Regent Aurelia Vess sends an envoy with a sealed offer: surrender the Lume, and no more highland valleys will be drowned. Refuse, and her legions march.\n\nThe envoy brings a ledger of the dead of every Ascension war. The numbers rise every time.\n\nYou refuse. The legions march.",
		"opening": "She is not wrong about the numbers. She is wrong about the answer.",
		"taunts": ["The envoy: \"Seventy-six Ascensions. Seventy-six wars. Do you want a seventy-seventh?\"", "The envoy: \"The Regent will remember you kindly. It is more than the Lume will do.\""],
		"victory": "The legion broke. The envoy, dying, pressed the ledger into your hand. On its last page, in the Regent's own hand: \"I am sorry, Jardas. Truly. But one of us has to be the monster.\""},
	{"id": "2-S2", "act": 1, "title": "The Silver Sisters", "map": "seven_fountains", "side": true, "jar": true,
		"opponents": [{"race": "sylvan", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": [],
		"briefing": "Not every Moura chose to fade. The Moura Court sold their Lume to the Dominion for eternity, and became silver-eyed, perfect and cold.\n\nThey have come for their sisters in the Seven Fountains. Ilduara will not ask you to fight them. She does not have to.",
		"opening": "Ilduara: \"They were the most beautiful of us. They still are.\"",
		"taunts": ["A silver Moura: \"Fading is a choice, sister. We chose not to.\"", "A silver Moura: \"The Jardas is dead, you know. Can you not smell it?\""],
		"victory": "The Moura Court withdrew. One silver sister stayed behind, weeping, and left a fourth jar at Ilduara's feet. \"For when you need to remember everything,\" she said."},
	{"id": "2-6", "survive": 480, "act": 1, "title": "Rising Water", "map": "thornwild",
		"opponents": [{"race": "sunspear", "difficulty": "hard"}, {"race": "sylvan", "difficulty": "normal"}], "difficulty": "Hard", "unlocks": ["3-1"],
		"briefing": "The Dominion has opened the sluices. The water is rising toward the Grove of Seven Fountains, and if the grove drowns, the Lioraen die with it.\n\nHold the grove until the Dominion's engineers are dead or gone.",
		"opening": "Ilduara: \"If the water reaches the roots, we sleep forever.\"",
		"taunts": ["A Dominion engineer: \"Open the second sluice!\"", "Ilduara: \"Hold, Jardas. Hold. I can hear my sisters dreaming.\""],
		"victory": "The water stopped at the roots. Ilduara, already half bark, touched your face with a hand like cold wood. \"You are cold, little one,\" she whispered. \"The living are never this cold.\""},
	# ---------------------------------------------------------------- ACT III
	{"id": "3-1", "act": 2, "title": "Boticas Cellars", "map": "boticas",
		"opponents": [{"race": "hollow", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": ["3-2", "3-S3"],
		"briefing": "In the last war, the elders of Boticas buried their Lume in clay jars under the cellar floors to hide it from the invaders. They called it the Wine of the Dead.\n\nThe jars are still down there. So are the dead who guard them.\n\nBoticas sits on old granite. Raise outposts on its veins and the valley's stone will pay for the digging.

The Ascension is pushing the old jars up out of the fields again. Where the Lume glows violet, hold the ground and dig, before the dead do.",
		"opening": "Wine buried for a war nobody alive remembers.",
		"taunts": ["The Compaña sings. This time you can hear the words, and they are your name.", "The Cross-Bearer: \"Go home. Please. Go home before you understand.\""],
		"victory": "The cellars were empty but for broken clay and one message scratched into the wall: SEVEN JARS. ONE FOR EACH MOUTH OF THE SPRING. The jars had been scattered across the highlands, as if someone knew you would come looking."},
	{"id": "3-S3", "act": 2, "title": "The Castro of Lesenho", "map": "castro_lesenho", "side": true,
		"opponents": [{"race": "karak", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": [],
		"briefing": "High on the Lesenho, the old castro's walls have begun to move. The Granitborn guardians of the hill fort are waking, and they do not know that their war ended two thousand years ago.\n\nCarvalho says only a Jardas can make them remember. He means: beat them first.",
		"opening": "Wake up, old stones. The war you are fighting is over.",
		"taunts": ["A guardian: \"The walls must hold. The walls must hold.\"", "Carvalho: \"Careful. Some of them are my grandfathers.\""],
		"victory": "When the last guardian knelt, the castro went quiet, and the stones settled back into walls. Carvalho stayed behind a long time, reading names cut into the gate that no one else could see."},
	{"id": "3-2", "act": 2, "title": "The Eldest Mask", "map": "larouco_road",
		"opponents": [{"race": "frostborn", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": ["3-3", "3-S1"],
		"briefing": "The Careto Host has come down from the Larouco in red and green fringes, with iron cowbells and horned masks. They block the only road to the Castro of Carvalhelhos.\n\nThey laugh while they fight. They have been laughing at you since the Act began.",
		"opening": "Cowbells in the snow. The Caretos are coming.",
		"taunts": ["O Velho: \"Welcome, cousin of the road!\"", "O Velho: \"How does it feel to walk without a shadow, cousin?\""],
		"victory": "O Velho took off his mask. Beneath it was another mask, and beneath that another. \"We chase the dead back into the earth each spring,\" he said. \"This year, cousin, we will have to chase you.\""},
	{"id": "3-3", "act": 2, "title": "The Castro Ledger", "map": "castro_carvalhelhos",
		"opponents": [{"race": "karak", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": ["3-4"],
		"briefing": "The Granitborn of Carvalhelhos turned themselves to stone so they could remember every Ascension. Their ledger of the dead holds every name the highlands ever lost.\n\nThey will not open it for a living person. Make them.",
		"opening": "Stone forgets nothing. That is exactly what I am afraid of.",
		"taunts": ["Thane-Lord Carvalho: \"Turn back. Some ledgers should stay closed.\"", "Thane-Lord Carvalho: \"Why do you think we will not let you read it, Jardas?\""],
		"victory": "Carvalho opened the ledger to the most recent page. Your name was written there, in fresh ink, dated the night of the Ascension. Cause of death: a Vorthak blade, at the Spring of Seven Mouths. You died that night. The Lume did not save you. It rose inside you, because the dead remember best."},
	{"id": "3-S1", "act": 2, "title": "Seventh Son", "map": "fojo_in_winter", "side": true, "jar": true,
		"opponents": [{"race": "sunspear", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": [],
		"briefing": "Dominion hunters are driving the Wolfveil clans into a fojo: seventh sons and their wolves, penned like cattle.\n\nSétimo, the Seventh, knows you. His wolves went silent when you passed in the first Act, and now you know why.",
		"opening": "Sétimo: \"The wolves never howl at the dead, Jardas.\"",
		"taunts": ["A Dominion hunter: \"Wolf pelts pay well in the capital.\"", "Sétimo: \"Free my pack, and we run at your side until the moon falls.\""],
		"victory": "The Wolfveil swore to you under the full moon. Sétimo dug a fifth jar out of the wolf-trap's floor with his bare hands."},
	{"id": "3-4", "act": 2, "title": "The Candle Road, Again", "map": "candle_road",
		"opponents": [{"race": "hollow", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": ["3-5", "3-S2"],
		"briefing": "Now you know what you are, the Compaña will not part for you any more. It will wait for you to join it.\n\nHunt the procession to its heart, and find the woman who carries the cross.",
		"opening": "I am dead. I am still walking. So are they.",
		"taunts": ["The Compaña: \"Take the candle. It is so much lighter than the Lume.\"", "The Cross-Bearer: \"I have walked for nineteen years. Let me walk a little longer.\""],
		"victory": "At the heart of the procession, under the hood, was a woman's face you had only seen in one faded painting over your grandmother's hearth."},
	{"id": "3-S2", "survive": 420, "act": 2, "title": "The Pilgrims' Bridge", "map": "pilgrims_bridge", "side": true, "jar": true,
		"opponents": [{"race": "hollow", "difficulty": "hard"}, {"race": "sunspear", "difficulty": "normal"}], "difficulty": "Hard", "unlocks": [],
		"briefing": "Some of the dead remember their names again and want to go home across the old stone bridge. The Dominion wants them to stay lost: remembered dead feed the Lume.\n\nEscort the pilgrims across.",
		"opening": "Remember their names. Say them out loud as they cross.",
		"taunts": ["A Dominion officer: \"Burn the bridge if you must.\"", "A pilgrim: \"My name was Amélia. I baked the bread at Salto for forty years.\""],
		"victory": "Two hundred and eleven dead crossed the bridge, each saying their name. The last left a sixth jar at the far end."},
	{"id": "3-5", "act": 2, "title": "The Cross-Bearer", "map": "leonors_cross",
		"opponents": [{"race": "hollow", "difficulty": "hard"}, {"race": "frostborn", "difficulty": "normal"}], "difficulty": "Hard", "unlocks": ["3-6"],
		"briefing": "The woman at the front of the procession is Leonor of Salto, your mother, who everyone said drowned in the lower pastures nineteen years ago.\n\nShe took up the Compaña's cross the night she drowned, and has walked beside your death ever since, waiting for the Ascension she knew would come. The Caretos want to drive her into the ground with the rest of the dead.",
		"opening": "Leonor: \"You have grown so tall. I am sorry. I am so sorry.\"",
		"taunts": ["O Velho: \"Winter must go into the ground, cousin. All of winter.\"", "Leonor: \"If I put the cross down, the procession takes whoever stands nearest. That is you.\""],
		"victory": "You held the Caretos back, and Leonor held the cross. She would not let it go, because the one thing the Compaña wanted was her child."},
	{"id": "3-6", "act": 2, "title": "Chase Out the Winter", "map": "four_peaks",
		"opponents": [{"race": "hollow", "difficulty": "hard"}, {"race": "sunspear", "difficulty": "hard"}], "difficulty": "Brutal", "unlocks": ["4-1"],
		"briefing": "The Dominion has found the procession and wants its dead: remembered or lost, they all feed the Lume.\n\nFight beside the Caretos and your mother to drive both the Compaña and the Dominion from the Larouco before spring.",
		"opening": "O Velho: \"Ring the bells, cousins! Chase out the winter!\"",
		"taunts": ["Aurelia Vess (by messenger): \"Your dead are my ammunition, Jardas.\"", "Leonor: \"Whatever happens, do not take the candle.\""],
		"victory": "Spring came to the Larouco. At home, Avó Brites was waiting at the spring. \"I knew,\" she said, before you asked. \"I spoke the esconjuro over your body, and the Lume answered. I would do it again. Forgive me or don't, but eat something. You are going south.\""},
	# ----------------------------------------------------------------- ACT IV
	{"id": "4-1", "act": 3, "title": "The Geira Road", "map": "geira_road",
		"opponents": [{"race": "sunspear", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": ["4-2"],
		"briefing": "The ancient road south, the Geira, is lined with milestones older than the Dominion. Each stone is a sleeping piece of Lume.\n\nWake them as you march. The Dominion will try to smash them first.\n\nThe Geira was built to carry gold up from the southern veins. Hold them and your war feeds itself. Lose them, and it feeds the Dominion's.",
		"opening": "Every milestone is a memory. Wake them.",
		"taunts": ["A legate: \"Break the stones! Every one!\"", "Leonor (far behind, on the road): \"I am still walking. I am right behind you.\""],
		"victory": "Forty milestones burned with Lume light all the way to the horizon. The Dominion saw the road glowing from its capital."},
	{"id": "4-2", "act": 3, "title": "Ironmaw Rising", "map": "ironmaw_mines",
		"opponents": [{"race": "grimtusk", "difficulty": "hard"}, {"race": "sunspear", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": ["4-3", "4-S1"],
		"briefing": "In the Dominion's Lume-iron mines, the slaves have revolted. They have taken the iron into their own flesh: tusked, huge and furious. They call themselves the Ironmaw.\n\nThey fight everyone. Warboss Brasa wants to know whose side you are on.",
		"opening": "Brasa: \"Everyone wants the Lume. Nobody wanted us.\"",
		"taunts": ["Warboss Brasa: \"Prove you are not just another master, Jardas.\"", "A Dominion overseer: \"Put the beasts back in the pit!\""],
		"victory": "Brasa spat iron and laughed. \"You fight like a slave with nothing to lose. I like you, dead thing. The Ironmaw will march with you as far as the Wall.\""},
	{"id": "4-S1", "act": 3, "title": "Chega de Bois", "map": "covelo", "side": true, "jar": true,
		"opponents": [{"race": "barrosan", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": [],
		"briefing": "The village of Covelo will not march with you. Their elders demand the old way: a Chega de Bois, the clash of two villages' bulls, with the whole valley's honor on the horns.\n\nWin, and the long-horned Barrosã bulls march south with you.",
		"opening": "The village bulls lock horns. The valley holds its breath.",
		"taunts": ["Covelo's elder: \"Our bull has never lost. Neither has our village.\"", "Avó Brites: \"Win this and they will follow you into the sea.\""],
		"victory": "Covelo's bull gave ground. Its elder, grinning, handed you the seventh jar, hidden for a century under the bull-pen floor. \"For the champion. As the old rules say.\""},
	{"id": "4-3", "act": 3, "title": "The Bronze Legions", "map": "plains_of_bronze",
		"opponents": [{"race": "sunspear", "difficulty": "brutal"}], "difficulty": "Brutal", "unlocks": ["4-4"],
		"briefing": "The Dominion's full field army waits on the plains before the Wall: bronze legions that have never lost a battle in seventy-seven years.\n\nThere is no clever way through. Win.",
		"opening": "Seventy-seven years undefeated. Today that ends.",
		"taunts": ["A legate: \"Hold the line! For the Regent! For a world without war!\"", "Warboss Brasa: \"I used to carry their water. Now I carry their heads.\""],
		"victory": "The legions broke for the first time in seventy-seven years. In the silence afterwards, the wind brought the sound of water: the Wall, holding back a whole drowned valley."},
	{"id": "4-4", "act": 3, "title": "Malrec's Last Offer", "map": "glass_heart",
		"opponents": [{"race": "vorthak", "difficulty": "brutal"}], "difficulty": "Brutal", "unlocks": ["4-5", "4-S2"],
		"briefing": "Malrec is back, dying, his glass spreading. He offers his glass heart: all the ash-glass Lume of Furna. With it, the Vorthak will march at your side.\n\nThe ash-glass Vorthak will not accept that deal without a fight. They never have.",
		"opening": "Malrec: \"I tried to stop the drowning once. I was not strong enough. Be stronger.\"",
		"taunts": ["A Veil Warlock: \"The master is giving us away!\"", "Malrec: \"When you reach the Wall, remember: you will be the one who chooses. Nobody else.\""],
		"victory": "Malrec died smiling. His glass heart glowed violet in your hands, and for a moment you saw Furna as it was: bells, bread, and children on the church steps."},
	{"id": "4-S2", "act": 3, "title": "The Monastery of the Júnias", "map": "junias", "side": true,
		"opponents": [{"race": "sunspear", "difficulty": "hard"}], "difficulty": "Hard", "unlocks": [],
		"briefing": "In the valley below Pitões lie the ruins of the monastery of Santa Maria das Júnias. The Dominion has turned it into an archive: every map of the Terras Frias, every record of the Ascensions, kept for the Regent's surveyors.\n\nBurn the maps, and the Dominion walks blind.",
		"opening": "The monks kept the valley's memory for six hundred years. Tonight we take it back.",
		"taunts": ["A surveyor: \"Knowledge belongs to those who can use it!\"", "A legate: \"Guard the archive. The Regent will not forgive its loss.\""],
		"victory": "The archive burned, all but one book: the monks' own chronicle of the Ascensions, which the Dominion had never bothered to read. In it, your name was already written."},
	{"id": "4-5", "act": 3, "title": "The Sun Regent", "map": "regents_canyon",
		"opponents": [{"race": "sunspear", "difficulty": "brutal"}, {"race": "sylvan", "difficulty": "hard"}], "difficulty": "Brutal", "unlocks": ["4-6A", "4-6B"],
		"briefing": "Aurelia Vess takes the field herself, with the Moura Court at her side.\n\nShe is not afraid of you. She is afraid of what comes after you.",
		"opening": "Aurelia Vess: \"I read your name in the Castro ledger, Jardas. You died. Let the rest of us live.\"",
		"taunts": ["Aurelia Vess: \"Every Ascension, more graves. I will end the Ascensions.\"", "Aurelia Vess: \"Do you know what the Lume wants? Do you know what it really is?\""],
		"victory": "Aurelia Vess knelt in the red sand and gave you the key to the Wall. \"I kept the Dominion alive for forty years,\" she said. \"You can have the Wall. You can have the choice. I hope it breaks you.\""},
	{"id": "4-6A", "act": 3, "title": "Break the Wall", "map": "rabagao_wall", "branch": "break",
		"opponents": [{"race": "sunspear", "difficulty": "brutal"}, {"race": "grimtusk", "difficulty": "hard"}], "difficulty": "Brutal", "unlocks": ["5-1"],
		"briefing": "Break the Rabagão Wall. The drowned Lume of seventy-seven years flows free, the highland springs wake, and the Mouras live.\n\nThe flood also takes the lowland towns: the Dominion's farms, and the families who had nothing to do with any of it. The Ironmaw, who were slaves in those towns, will not forgive you for their neighbours.\n\nChoosing this road seals the other forever.",
		"opening": "Open the sluices. Let the valleys breathe.",
		"taunts": ["Warboss Brasa: \"My sister lives in the lowlands, dead thing!\"", "The water, very loud: a thousand bells ringing under the flood."],
		"victory": "The Wall broke. The Lume of Furna and every drowned village roared up the valleys, and the highland springs burned bright for the first time in a lifetime. Downstream, the lowland towns went under. Somewhere, the Ascension began."},
	{"id": "4-6B", "act": 3, "title": "Seize the Wall", "map": "rabagao_wall", "branch": "seize",
		"opponents": [{"race": "sunspear", "difficulty": "brutal"}, {"race": "lioraen", "difficulty": "hard"}], "difficulty": "Brutal", "unlocks": ["5-1"],
		"briefing": "Seize the Rabagão Wall and hold it. The water stays; the lowlands live. The Lume of the drowned valleys will be yours alone to open or keep shut, exactly as Malrec always said it must be.\n\nThat breaks the fourth line of the First Oath: Lume may never be owned. The Lioraen will not forgive you for their sisters.\n\nChoosing this road seals the other forever.",
		"opening": "Take the Wall. Hold the key. Carry it alone.",
		"taunts": ["Ilduara (a voice in the trees): \"You swore nothing to us. But I thought you understood.\"", "A Dominion engineer: \"Long live the new Regent...\""],
		"victory": "You held the Wall and the key. The lowlands lived. In the highlands the springs fell quiet, and the Lume inside you grew heavy and hungry. Somewhere, the Ascension began."},
	# ------------------------------------------------------------------ ACT V
	{"id": "5-1", "act": 4, "title": "The Burning Geira", "map": "burning_geira",
		"opponents": [{"race": "hollow", "difficulty": "brutal"}], "difficulty": "Brutal", "unlocks": ["5-2"],
		"briefing": "The milestones of the Geira flare like torches, and the dead walk in daylight.\n\nThe Granitborn were right. Stone forgets nothing, and the Lume is not a power. It is every person the highlands ever lost, and it wants to ascend: to become a realm, and pull the living into memory with it.\n\nThe seventy-six Jardas before you each stopped it, and each died doing it. The Ascension wars were only the living fighting over who would carry the thing that kills its carrier.\n\nEven the veins burn violet now. When the Lume flares through them they run twice as rich, and every army on the field will come for them.",
		"opening": "The dead are walking in the sun. It has begun.",
		"taunts": ["The Compaña, all at once: \"Come home. Come home. Come home.\"", "Leonor: \"I am still here. I am still holding the cross.\""],
		"victory": "The Geira burned out behind you. Every milestone pointed the same way: north, to Salto."},
	{"id": "5-2", "act": 4, "title": "Montalto Besieged", "map": "montalto",
		"opponents": [{"race": "sunspear", "difficulty": "brutal"}, {"race": "vorthak", "difficulty": "hard"}, {"race": "grimtusk", "difficulty": "normal"}], "difficulty": "Brutal", "unlocks": ["5-3"],
		"briefing": "Every army you broke on the road is at Montalto's walls: the Dominion's remnants, the Vorthak who hated Malrec's deal, and the Ironmaw, whatever you did at the Wall.\n\nThey all want the Lume before it ascends. Hold the old keep.",
		"opening": "Every enemy I made, all at once. Fair enough.",
		"taunts": ["A Dominion legate: \"Give us the Lume and we will end this!\"", "Warboss Brasa: \"Nothing personal, dead thing. Everyone needs a win.\""],
		"victory": "Montalto held. On the tower, as always on the thirteenth, someone had lit the queimada."},
	{"id": "5-3", "act": 4, "title": "The Moura's Last Spring", "map": "last_spring",
		"opponents": [{"race": "sylvan", "difficulty": "brutal"}, {"race": "hollow", "difficulty": "hard"}], "difficulty": "Brutal", "unlocks": ["5-4", "5-S1"],
		"briefing": "The Moura Court has come to drink the last Lioraen fountain dry before the Ascension. If it falls, the last of Ilduara's people fade forever.\n\nWhatever you did at the Wall, this spring is still worth defending.",
		"opening": "Ilduara (a voice in the trees): \"Remember us. That is all we ever asked.\"",
		"taunts": ["A silver Moura: \"We will be all that is left of the Mouras, Jardas. The pretty ones.\"", "The Compaña, singing, very close now."],
		"victory": "The last fountain ran clear. A young oak stood where Ilduara had faded, and on its bark, carved in no hand you know, was your name."},
	{"id": "5-S1", "act": 4, "title": "The Last Queimada", "map": "witches_saddle", "side": true,
		"opponents": [{"race": "hollow", "difficulty": "brutal"}, {"race": "sylvan", "difficulty": "hard"}], "difficulty": "Brutal", "unlocks": [],
		"briefing": "Before the final oath, the old women say, the queimada must burn: aguardente, sugar and the spell spoken over the blue flame to drive the dark away from the valley.\n\nThe Compaña and the Moura Court both want that fire unlit. Hold the witches' circle until the spell is spoken.",
		"opening": "Mouchos, coruxas, sapos e bruxas. Let the fire hear it.",
		"taunts": ["The Candle-King: \"No fire burns longer than a candle.\"", "A Moura: \"Your spells are older than you think, Jardas. So are we.\""],
		"victory": "The queimada burned blue until dawn, and the valley was quiet. Leonor drank the first cup, looked at you for a long time, and said, 'Now you can go.'"},
	{"id": "5-4", "act": 4, "title": "The Glass Choir", "map": "furna_in_ashes",
		"opponents": [{"race": "vorthak", "difficulty": "brutal"}, {"race": "hollow", "difficulty": "hard"}], "difficulty": "Brutal", "unlocks": ["5-5"],
		"briefing": "Every ash-glass creature the Vorthak ever made has risen, singing in the voices of drowned Furna. The Lume is calling its lost pieces home.\n\nSilence the choir, or it will carry you with it.",
		"opening": "They are singing Malrec's name. And mine.",
		"taunts": ["The Glass Choir: \"Furna remembers. Furna ascends.\"", "Malrec's voice, from the glass: \"Be stronger than me, Jardas. Please.\""],
		"victory": "The choir fell silent. In the quiet you could hear, very far north, the spring of Salto running over."},
	{"id": "5-5", "act": 4, "title": "Salto Remembers", "map": "salto_valley",
		"opponents": [{"race": "hollow", "difficulty": "brutal"}, {"race": "frostborn", "difficulty": "hard"}], "difficulty": "Brutal", "unlocks": ["5-6"],
		"briefing": "You come home. Salto is empty. The communal oven is warm, and bread is baking, and nobody is there.\n\nThe village has gone to the spring. The Compaña is walking through the streets, and the Caretos are ringing their bells against it one last time.",
		"opening": "The oven is warm. Somebody is still baking. Somebody still remembers.",
		"taunts": ["O Velho: \"Last dance, cousin. Last dance of the winter.\"", "Avó Brites (from the spring): \"Come home, child. Come home and finish it.\""],
		"victory": "The streets were clear. The whole village stood at the Spring of Seven Mouths, holding candles, waiting for you."},
	{"id": "5-6", "act": 4, "title": "The Ascendant", "map": "salto_ascendant",
		"opponents": [{"race": "hollow", "difficulty": "brutal"}, {"race": "vorthak", "difficulty": "hard"}], "difficulty": "Brutal", "unlocks": ["5-7"],
		"briefing": "The Lume rises from the Spring of Seven Mouths and takes a shape: yours. It wears your face, your walk, your grandmother's scarf. It is the Ascendant, every highland dead in one body, and it is so tired of being forgotten.\n\nDefeat it. Not to kill it: to make it listen.",
		"opening": "It has my face. Of course it has my face.",
		"taunts": ["The Ascendant, in your voice: \"We were forgotten. You died forgotten. Why defend them?\"", "The Ascendant: \"Every one of your seventy-six ancestors said no. Every one of them is inside me.\""],
		"victory": "The Ascendant knelt at the spring. It did not die; it waited. All seven mouths of the spring opened at once. The last battle was not against anyone. It was about what the highlands would become."},
	{"id": "5-7", "survive": 600, "act": 4, "title": "The Seventy-Seventh Oath", "map": "hollowspan",
		"opponents": [{"race": "sunspear", "difficulty": "brutal"}, {"race": "hollow", "difficulty": "brutal"}, {"race": "vorthak", "difficulty": "brutal"}], "difficulty": "Brutal", "unlocks": [],
		"briefing": "Every realm comes to Salto for the end: the Dominion to drown it, the dead to claim it, the ash-glass to burn it. Hold the Spring of Seven Mouths until the Oath is spoken.\n\nWhat Oath you speak depends on everything you have done.",
		"opening": "Avó Brites: \"Owls and toads and witches... and one more oath. Hold them, child.\"",
		"taunts": ["Every voice of the Compaña, at once: \"Remember us.\"", "Leonor: \"Whatever you choose, I am proud of you.\""],
		"victory": "ENDING"},
]

## Ending chronicles for the final chapter (chosen in ending_text).
const ENDINGS := {
	"chega": "THE CHEGA (true ending). You poured the seven jars of Wine of the Dead into the spring, and the whole highland remembered at once: every name, every oven, every bull. No single person carries the Lume now. Every village carries its share, like the common pasture and the shared bull. There is no Jardas. There is no Ascension. There will be no seventy-eighth war. Leonor put down the cross at last and sat by the fire with her mother and her child. At midnight Avó Brites spoke the esconjuro, and the fire answered from every hearth in the Terras Frias.",
	"break": "THE OATH KEPT. You walked into the spring and took the Lume with you into the Compaña, as seventy-six Jardas did before you. Leonor put down the cross. The procession passed through Salto one last time, and this time the whole village knew every name. The springs of the highlands run free, and the lowlands are still drowned. In seventy-seven years the Lume will rise again. The ledger at Carvalhelhos has a new line: two names, mother and child, side by side.",
	"seize": "THE ASCENDANT REALM. You did not walk into the spring. You became it. The Lume is yours, the Wall is yours, and the highlands are safe under a ruler who never sleeps and never dies. The Dominion kneels. The Mouras are gone. Salto bakes bread every morning for a Jardas who can no longer taste it. In seventy-seven years the Lume will try to rise again, and for the first time in history, the Ascension war will be fought against you.",
}

## Every hero is the Jardas of Salto; their faction is their blood. These
## lines join the prologue and the Act III reveal so a Lioraen or Vorthak
## hero has their own place in the same story.
const ORIGINS := {
	"grimtusk": {
		"1-1": "You were born in the Dominion's iron pits and carried out of them as a child by a smuggler from Tourém. Avó Brites took you in without a question. The iron is still in your jaw.",
		"3-3": "Beside your name, the ledger lists your line: born in chains, freed in Salto. The Ironmaw revolt will know your name before you know theirs.",
	},
	"sylvan": {
		"1-1": "You are a Moura of the Court who refused eternity. You fled the silver halls and hid in Salto as a girl who bakes bread and never ages. Avó Brites keeps your secret.",
		"3-3": "The ledger lists you twice: once among the Moura Court, crossed out, and once in Salto, in Avó Brites's hand: 'ours'.",
	},
	"karak": {
		"1-1": "You are Granitborn: a castro child who would not turn to stone, sent down the mountain to live among the living. Salto raised you; the stone still calls.",
		"3-3": "Carvalho reads your name slowly. 'You were meant to be one of us,' he says. 'Instead you chose to be mortal. And then you died anyway.'",
	},
	"sunspear": {
		"1-1": "You were a Dominion surveyor's child, left behind in Salto when your family went south. You grew up in the village your people meant to drown.",
		"3-3": "Beside your name, the ledger lists your line: Aurean, a surveyor's house. The Dominion measured this valley. You were born to measure it too.",
	},
	"wyldkin": {
		"1-1": "You are a seventh child of a seventh child. The wolves came for you as a baby, and Avó Brites chased them off with a burning broom. The moon has never let you go.",
		"3-3": "The ledger lists you as a seventh of a seventh. 'Those never stay dead,' Carvalho mutters. 'The moon will not allow it.'",
	},
	"hollow": {
		"1-1": "You were born in the procession. Your mother gave birth walking behind the cross, and a Salto shepherd carried you out of the Compaña at dawn. You have always seen candles no one else can see.",
		"3-3": "The ledger lists you twice: once among the dead of the procession, and once among the living of Salto. Now both entries are true.",
	},
	"frostborn": {
		"1-1": "You were found on the Larouco after an Entrudo, a baby wrapped in a Careto's red-and-green fringes. The masks have visited Salto every winter since, to look at you.",
		"3-3": "Beside your name, the ledger bears a Careto's mark: a mask with no face. O Velho, it seems, has been waiting a long time.",
	},
	"lioraen": {
		"1-1": "You were a foundling. Avó Brites found you as a baby in the Spring of Seven Mouths, wrapped in bark, and raised you as her own. The Lioraen of the groves have always watched you from the trees.",
		"3-3": "Carvalho turns one page back. Beside your name is a second entry: born of a Moura of the Seven Fountains, given to the spring to be remembered. The Mouras gave you to Salto. The spring gave you back.",
	},
	"vorthak": {
		"1-1": "Your blood is Furna's. Your grandmother fled the drowned valley as a girl, and the violet ash-glass shows in your veins when you are angry. Salto raised you anyway.",
		"3-3": "Beside your name, the ledger lists your line: Furna, drowned. The Lume in you and the ash-glass in the Vorthak are the same fire, one burning and one rotted.",
	},
}

## Seconds to hold out in a survival chapter (0 = conquest).
static func survive_seconds(id: String) -> int:
	return int(find(id).get("survive", 0))

## Battle events by chapter. "waves": enemy reinforcements at a battle time
## (seconds), marching on the player's base. "allies": friendly troops that
## join the player at the start. Unit ids from unit_defs.
const EVENTS := {
	"1-6": {"waves": [{"at": 300, "team": 1, "units": ["vorthak_ash_thrall", "vorthak_ash_thrall", "vorthak_ash_thrall", "vorthak_gloom_hound", "vorthak_gloom_hound"], "line": "Malrec: \"Release the kennels!\""}]},
	"2-6": {"waves": [{"at": 240, "team": 1, "units": ["sunspear_legion", "sunspear_legion", "sunspear_legion", "sunspear_bowman", "sunspear_bowman"], "line": "A Dominion engineer: \"Open the second sluice! Send the reserve!\""}]},
	"3-6": {"allies": {"units": ["frostborn_reaver", "frostborn_reaver", "frostborn_reaver", "frostborn_shieldmaiden"], "line": "O Velho: \"The Caretos ride with you, cousin!\""}},
	"4-3": {"allies": {"units": ["grimtusk_grunt", "grimtusk_grunt", "grimtusk_berserker", "grimtusk_bowcrusha"], "line": "Warboss Brasa: \"The Ironmaw keep their word. Point us at the bronze.\""},
		"waves": [{"at": 420, "team": 1, "units": ["sunspear_phalanx", "sunspear_phalanx", "sunspear_charioteer", "sunspear_charioteer"], "line": "A legate: \"The Wall's garrison marches!\""}]},
	"4-S1": {"allies": {"units": ["barrosan_clan_levy", "barrosan_clan_levy"], "line": "Covelo's young men cheer for your bull."}},
	"5-2": {"allies": {"units": ["barrosan_spear_guard", "barrosan_spear_guard", "barrosan_spear_guard", "barrosan_crag_archer", "barrosan_crag_archer", "barrosan_crag_archer"], "line": "The castellan of Montalto: \"This keep has never opened its gates to an enemy. Not today.\""}},
	"5-5": {"allies": {"units": ["frostborn_reaver", "frostborn_reaver", "frostborn_berserker"], "line": "O Velho: \"Last dance, cousin. We dance it together.\""}},
	"5-7": {"allies": {"units": ["wyldkin_clawwarrior", "wyldkin_clawwarrior", "wyldkin_direwolf", "wyldkin_direwolf"], "line": "Sétimo: \"The wolves remember who freed them.\""},
		"waves": [{"at": 180, "team": 1, "units": ["sunspear_legion", "sunspear_legion", "sunspear_charioteer"], "line": "The Dominion's last legion comes up the road."},
			{"at": 360, "team": 2, "units": ["hollow_skeleton", "hollow_skeleton", "hollow_skeleton", "hollow_wraith", "hollow_wraith"], "line": "The Compaña: \"Remember us... remember us...\""},
			{"at": 480, "team": 3, "units": ["vorthak_rift_blade", "vorthak_rift_blade", "vorthak_veil_warlock"], "line": "The Glass Choir sings from the ruins of Furna."}]},
}

## A relic from each side road, given the first time it is won. Items use
## the War Chest format (hero_progression reads "stats").
const RELICS := {
	"1-S3": {"name": "Trovão's Ribbon", "slot": "amulet", "rarity": "epic", "stats": {"hp": 70, "armor": 2}, "flags": {}, "desc": "A red ribbon from the horns of the people's bull. Whoever wears it does not give ground."},
	"2-S3": {"name": "Smuggler's Tin Compass", "slot": "relic", "rarity": "epic", "stats": {"speed": 0.5, "mana_regen": 1.0}, "flags": {}, "desc": "It always points home. It has never been wrong."},
	"3-S3": {"name": "Castro Gatestone", "slot": "off_hand", "rarity": "epic", "stats": {"armor": 4, "hp": 110}, "flags": {}, "desc": "A fist-sized stone from the gate of the Lesenho castro. It is always warm."},
	"4-S2": {"name": "Chronicle of the Júnias", "slot": "relic", "rarity": "epic", "stats": {"mana": 80, "heal_power": 15}, "flags": {}, "desc": "The monks' chronicle of every Ascension. The last page is still blank."},
	"5-S1": {"name": "Queimada Cup", "slot": "amulet", "rarity": "epic", "stats": {"dmg": 12, "mana": 60}, "flags": {}, "desc": "A clay cup still smelling of burnt aguardente. The blue flame never quite goes out."},
	"1-S1": {"name": "Fojo Hunter's Cloak", "slot": "cloak", "rarity": "rare", "stats": {"speed": 0.4, "armor": 2}, "flags": {}, "desc": "Wolf-gray wool from the trap walls. The pack does not hunt whoever wears it."},
	"1-S2": {"name": "Esconjuro Bowl", "slot": "relic", "rarity": "rare", "stats": {"mana": 40, "mana_regen": 1.5}, "flags": {}, "desc": "The clay bowl of the witch-night. The blue flame still flickers in it."},
	"2-S1": {"name": "Unlit Candle", "slot": "amulet", "rarity": "epic", "stats": {"hp": 90, "heal_power": 10}, "flags": {}, "desc": "Never light it. Never give it away."},
	"2-S2": {"name": "Silver Tear", "slot": "ring1", "rarity": "epic", "stats": {"dmg": 8, "mana": 30}, "flags": {}, "desc": "A Moura's tear, turned to silver. It is always cold."},
	"3-S1": {"name": "Seventh Son's Fang", "slot": "main_hand", "rarity": "epic", "stats": {"dmg": 16, "attack_speed": 0.1}, "flags": {}, "desc": "Sétimo's gift. It hums under the full moon."},
	"3-S2": {"name": "Pilgrim's Roll of Names", "slot": "relic", "rarity": "epic", "stats": {"aura_dmg": 3, "heal_power": 12}, "flags": {}, "desc": "Two hundred and eleven names, each said aloud at the bridge."},
	"4-S1": {"name": "Horn of the Barrosã Bull", "slot": "off_hand", "rarity": "legendary", "stats": {"hp": 140, "armor": 4, "aura_dmg": 2}, "flags": {}, "desc": "The champion's horn from the Chega de Bois. The valley bows to whoever carries it."},
}

## What an enemy commander says when their stronghold falls or their hero
## dies, by faction.
const REACTIONS := {
	"vorthak": {"hq": "The Cabal: \"Furna drowned once. We will not drown twice!\"", "hero": "A thrall wails: \"The binder is gone. Who will hold the glass together?\""},
	"sunspear": {"hq": "A legate: \"Fall back! Fall back to the Wall!\"", "hero": "A centurion: \"The legate is down! Hold formation!\""},
	"lioraen": {"hq": "The grove sighs, and a hundred leaves fall at once.", "hero": "The Lioraen: \"Remember her. Please, remember her.\""},
	"hollow": {"hq": "The candles gutter. The procession stops, and waits.", "hero": "The Compaña: \"The Candle-King falls... another will carry the light.\""},
	"frostborn": {"hq": "O Velho laughs: \"Well danced, cousin! Well danced!\"", "hero": "The bells go silent across the snow."},
	"wyldkin": {"hq": "The pack scatters into the trees, howling.", "hero": "Every wolf on the hillside howls at once."},
	"karak": {"hq": "Carvalho: \"Write it in the ledger. We were beaten fairly.\"", "hero": "Stone grinds on stone, like a mountain grieving."},
	"grimtusk": {"hq": "Brasa: \"You broke our pit! Fine! We never liked it!\"", "hero": "The Ironmaw roar their fallen warboss's name."},
	"sylvan": {"hq": "A silver Moura: \"This is not how eternity was supposed to end.\"", "hero": "The Moura Court's silver dims to gray."},
	"barrosan": {"hq": "Covelo's elder: \"The bull knows when it is beaten. So do we.\"", "hero": "The rival clans lower their banners."},
}

## The Jardas's first words, by faction, on the night of the Ascension.
const ORIGIN_OPENINGS := {
	"grimtusk": "Iron in my jaw and fire in my hands. Salto is mine to guard.",
	"sylvan": "I left eternity for a village. Tonight I find out if it was worth it.",
	"karak": "Stone forgets nothing. Neither will I.",
	"sunspear": "My people came to drown this valley. I stayed to save it.",
	"wyldkin": "The moon is full. The Lume is burning. The wolves are quiet. Good.",
	"hollow": "I have walked with the dead before. Tonight, they walk with me.",
	"frostborn": "Ring the bells. Chase out the winter. Tonight it starts with me.",
	"lioraen": "The spring remembers me. It always has.",
	"vorthak": "The ash in my veins is burning. For once, it is burning for Salto.",
}

## Light and weather a chapter lays over its map: the night of the
## Ascension, burning villages, the flood, the Regent's dusk.
const MOODS := {
	"night": {"sun_energy": 0.62, "sun_color": Color(0.62, 0.70, 0.98), "sun_pitch": -42.0, "ambient_energy": 0.46,
		"fog_color": Color(0.24, 0.30, 0.46), "fog_density": 0.0007, "grade_contrast": 1.06, "grade_saturation": 0.8, "grade_brightness": 1.0},
	"ember": {"sun_energy": 0.85, "sun_color": Color(1.0, 0.56, 0.32), "sun_pitch": -24.0, "ambient_energy": 0.36,
		"fog_color": Color(0.55, 0.30, 0.22), "fog_density": 0.0010, "grade_contrast": 1.1, "grade_saturation": 1.08, "grade_brightness": 0.95},
	"storm": {"sun_energy": 0.62, "sun_color": Color(0.74, 0.80, 0.86), "ambient_energy": 0.44,
		"fog_color": Color(0.46, 0.52, 0.58), "fog_density": 0.0016, "grade_contrast": 1.04, "grade_saturation": 0.72, "grade_brightness": 0.93},
	"dusk": {"sun_energy": 0.8, "sun_color": Color(1.0, 0.70, 0.46), "sun_pitch": -18.0, "ambient_energy": 0.38,
		"fog_color": Color(0.78, 0.58, 0.48), "fog_density": 0.0008, "grade_contrast": 1.06, "grade_saturation": 1.05, "grade_brightness": 0.97},
}
const CHAPTER_MOODS := {
	"1-1": "night", "1-2": "ember", "1-S2": "night", "1-6": "ember",
	"2-S1": "night", "2-4": "storm", "2-6": "storm",
	"3-4": "night", "3-S2": "night", "3-5": "night",
	"4-5": "dusk", "5-1": "ember", "5-6": "dusk", "5-7": "ember",
}

static func opening_for(id: String, race: String) -> String:
	if id == "1-1" and ORIGIN_OPENINGS.has(race):
		return String(ORIGIN_OPENINGS[race])
	return String(find(id).get("opening", ""))

static func is_side(id: String) -> bool:
	return bool(find(id).get("side", false))

static func briefing_for(id: String, race: String) -> String:
	var text := String(find(id).get("briefing", ""))
	var extra := String(ORIGINS.get(race, {}).get(id, ""))
	return text + ("

" + extra if extra != "" else "")

static func all() -> Array:
	return CHAPTERS

static func find(id: String) -> Dictionary:
	for c in CHAPTERS:
		if String(c["id"]) == id:
			return c
	return {}

static func index_of(id: String) -> int:
	for i in CHAPTERS.size():
		if String(CHAPTERS[i]["id"]) == id:
			return i
	return -1

static func chapters_in_act(act: int) -> Array:
	var out: Array = []
	for c in CHAPTERS:
		if int(c["act"]) == act:
			out.append(c)
	return out

## The ending chronicle for the final battle, from the saved campaign state.
static func ending_text(camp: Dictionary) -> String:
	if int(camp.get("jars", []).size()) >= JARS_TOTAL:
		return ENDINGS["chega"]
	return ENDINGS["seize"] if String(camp.get("choice", "break")) == "seize" else ENDINGS["break"]

static func victory_text(id: String, camp: Dictionary) -> String:
	var c := find(id)
	if c.is_empty():
		return ""
	if String(c.get("victory", "")) == "ENDING":
		return ending_text(camp)
	return String(c.get("victory", ""))
