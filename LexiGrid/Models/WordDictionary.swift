import Foundation

struct WordEntry: Hashable {
    let word: String
    let partOfSpeech: String
    let definition: String
    let clue: String
    let example: String
}

enum WordDictionary {
    // Answer words are intentionally separate from accepted guesses. Every
    // possible answer is familiar, family-friendly, and fully described.
    private static let answerEntries: [WordEntry] = [
        entry("APPLE", "noun", "A round fruit with crisp flesh.", "A crisp fruit often packed in a lunch.", "She sliced an apple for a snack."),
        entry("BEACH", "noun", "A sandy or pebbly shore beside water.", "A place where waves meet the land.", "We walked along the beach at sunset."),
        entry("BLOOM", "verb", "To produce flowers or flourish.", "What a flower does in spring.", "The roses bloom in early summer."),
        entry("BRAVE", "adjective", "Ready to face danger or difficulty.", "Showing courage when something feels scary.", "The brave climber continued upward."),
        entry("BREAD", "noun", "Food made from flour and baked dough.", "A bakery staple used for toast.", "The warm bread smelled wonderful."),
        entry("BRICK", "noun", "A rectangular block used for building.", "A small building block made from fired clay.", "Each brick was carefully placed."),
        entry("CHARM", "noun", "A quality that delights or attracts.", "A delightful quality or lucky object.", "The village has plenty of charm."),
        entry("CHEER", "verb", "To encourage with happy shouts.", "What supportive fans do from the stands.", "The crowd began to cheer."),
        entry("CLOUD", "noun", "A visible mass of water droplets in the sky.", "A soft-looking shape drifting across the sky.", "One cloud covered the sun."),
        entry("CORAL", "noun", "A hard marine structure made by tiny animals.", "A colorful reef-building sea organism.", "Bright fish swam around the coral."),
        entry("CRANE", "noun", "A tall bird or a machine that lifts loads.", "A long-legged bird or lifting machine.", "The crane raised the steel beam."),
        entry("DANCE", "verb", "To move rhythmically to music.", "Moving your body to a beat.", "They dance whenever that song plays."),
        entry("DREAM", "noun", "Images during sleep or a cherished hope.", "A sleeping story or future ambition.", "Her dream is to become a pilot."),
        entry("EARTH", "noun", "Our planet, or soil and ground.", "The planet we call home.", "Earth travels around the sun."),
        entry("EMBER", "noun", "A small glowing piece in a dying fire.", "A tiny glow left after a fire fades.", "One ember still glowed."),
        entry("FIELD", "noun", "An open area of land.", "Open land used for crops or sport.", "The horses crossed the field."),
        entry("FLAME", "noun", "The glowing, hot part of a fire.", "The bright dancing part of a fire.", "The candle flame flickered."),
        entry("FRESH", "adjective", "New, clean, or recently made.", "Recently made or pleasantly clean.", "We bought fresh bread."),
        entry("FROST", "noun", "A thin layer of ice crystals.", "A delicate icy coating on a cold morning.", "Frost covered the grass."),
        entry("GIANT", "noun", "A being or thing of unusually great size.", "Something much larger than usual.", "A giant tree stood beside the road."),
        entry("GLADE", "noun", "An open space surrounded by trees.", "A sunny clearing in a forest.", "Deer rested in the quiet glade."),
        entry("GRACE", "noun", "Elegance of movement or manner.", "Smooth elegance in movement or behavior.", "The skater moved with grace."),
        entry("GRAPE", "noun", "A small juicy fruit growing in clusters.", "A vine fruit that can become a raisin.", "He picked a grape from the bunch."),
        entry("GREEN", "adjective", "The color between blue and yellow.", "The color of healthy grass.", "The leaves remained green."),
        entry("HEART", "noun", "The organ that pumps blood.", "The organ associated with love.", "Exercise keeps your heart healthy."),
        entry("HONEY", "noun", "A sweet food made by bees.", "A golden sweetness made in a hive.", "She added honey to her tea."),
        entry("HOUSE", "noun", "A building designed as a home.", "A building where people live.", "Their house has a red door."),
        entry("LIGHT", "noun", "Visible energy that makes sight possible.", "It lets you see in darkness.", "Morning light filled the room."),
        entry("MAPLE", "noun", "A tree known for sweet sap.", "A tree whose sap makes syrup.", "A maple leaf fell onto the path."),
        entry("MUSIC", "noun", "Sounds organized into rhythm and melody.", "Melody and rhythm arranged for listening.", "Soft music played in the café."),
        entry("NOBLE", "adjective", "Having admirable qualities or dignity.", "Honorable and high-minded.", "Helping others was a noble goal."),
        entry("OCEAN", "noun", "A vast body of salt water.", "A vast expanse of salt water.", "The ocean stretched to the horizon."),
        entry("OLIVE", "noun", "A small oval fruit used for food and oil.", "A small fruit often pressed for oil.", "An olive rested on the salad."),
        entry("PEARL", "noun", "A smooth gem formed inside a shellfish.", "A round gem formed inside an oyster.", "The necklace held a single pearl."),
        entry("PLANT", "noun", "A living organism that grows using sunlight.", "A living thing with roots and leaves.", "The plant leaned toward the window."),
        entry("QUEST", "noun", "A long search for something important.", "An adventurous search for a goal.", "They began a quest for the map."),
        entry("RIVER", "noun", "A large natural stream of flowing water.", "Flowing water traveling toward a lake or sea.", "The river wound through the valley."),
        entry("ROBIN", "noun", "A small songbird with a colored breast.", "A familiar garden songbird.", "A robin landed on the fence."),
        entry("SHORE", "noun", "Land along the edge of water.", "The land at the edge of a lake or sea.", "Boats rested near the shore."),
        entry("SMILE", "noun", "A pleased or friendly facial expression.", "A happy expression made with the mouth.", "Her smile welcomed everyone."),
        entry("SOLAR", "adjective", "Relating to or powered by the sun.", "Powered by energy from the sun.", "Solar panels covered the roof."),
        entry("SPARK", "noun", "A tiny fiery particle.", "A tiny flash that can begin a fire.", "A spark rose from the campfire."),
        entry("STONE", "noun", "A small piece of hard mineral matter.", "A small, hard piece of rock.", "She skipped a stone across the pond."),
        entry("STORM", "noun", "Severe weather with wind or precipitation.", "Powerful weather with wind, rain, or thunder.", "The storm passed before dawn."),
        entry("SWEET", "adjective", "Having the pleasant taste of sugar.", "Tasting like sugar or honey.", "The berries were sweet."),
        entry("TIGER", "noun", "A large striped wild cat.", "A powerful striped cat from Asia.", "The tiger moved silently."),
        entry("TRAIL", "noun", "A path through the countryside.", "A marked path through nature.", "We followed the trail uphill."),
        entry("WATER", "noun", "The clear liquid essential to life.", "A clear liquid every living thing needs.", "Please drink plenty of water."),
        entry("WHEAT", "noun", "A cereal plant used to make flour.", "A golden grain often ground into flour.", "The farmer harvested the wheat."),
        entry("WORLD", "noun", "Earth and all its people and places.", "Our planet and everything on it.", "People around the world celebrated.")
    ]

    private static let entriesByWord = Dictionary(uniqueKeysWithValues: answerEntries.map { ($0.word, $0) })
    private static let blockedWords: Set<String> = [
        "ARSED", "BARFS", "FARTS", "FECES", "FUCKS", "GANJA", "GROPE", "NEGRO",
        "PENIS", "POOPS", "RETAR", "SEXED", "SEXES", "SHAGS", "SHITE", "TURDS",
        "TWATS", "WANKS", "WHORE"
    ]
    private static let acceptedWords = Set(Global.commonWords)
        .union(entriesByWord.keys)
        .filter { $0.count == 5 && $0.allSatisfy(\.isLetter) && !blockedWords.contains($0) }

    private static func entry(_ word: String, _ part: String, _ definition: String,
                              _ clue: String, _ example: String) -> WordEntry {
        WordEntry(word: word, partOfSpeech: part, definition: definition, clue: clue, example: example)
    }

    static func randomAnswer() -> String { answerEntries.randomElement()?.word ?? "APPLE" }

    static func isAccepted(_ word: String) -> Bool {
        acceptedWords.contains(word.trimmingCharacters(in: .whitespacesAndNewlines).uppercased())
    }

    static func entry(for word: String) -> WordEntry {
        entriesByWord[word.uppercased()] ?? WordEntry(
            word: word.uppercased(), partOfSpeech: "word", definition: "An accepted five-letter word.",
            clue: "A valid five-letter word.", example: ""
        )
    }

    static func definition(for word: String) -> String { entry(for: word).definition }
}
