package org.iremia.iremia.domain.engines

/**
 * Data model for a single memory card.
 */
data class WellnessMemoryCard(
    val id: Int,
    val content: String,
    var isFaceUp: Boolean = false,
    var isMatched: Boolean = false
)

/**
 * Logic engine for the Memory matching game.
 * Manages card shuffling, selection validation, and game-over states.
 */
class MemoryEngine {
    private val emojis = listOf("🧠", "☀️", "🌿", "🧘", "💧", "☁️")
    var cards = mutableListOf<WellnessMemoryCard>()
    var firstSelectedIndex: Int? = null
    var secondsRemaining = 60
    var isGameOver = false

    init {
        setupGame()
    }

    /**
     * Initializes a new game session with shuffled emoji pairs.
     */
    fun setupGame() {
        val gameContent = (emojis + emojis).shuffled()
        cards = gameContent.mapIndexed { index, emoji ->
            WellnessMemoryCard(id = index, content = emoji)
        }.toMutableList()
        secondsRemaining = 60
        isGameOver = false
    }

    /**
     * Logic for card selection.
     * @return True if a matching pair was found.
     */
    fun handleSelection(index: Int): Boolean {
        val card = cards[index]
        if (card.isFaceUp || card.isMatched || firstSelectedIndex == index) return false

        val firstIndex = firstSelectedIndex
        if (firstIndex == null) {
            // NOTE: Automatically close any previously unmatched cards before starting a new turn.
            cards.forEach { if (!it.isMatched) it.isFaceUp = false }
            card.isFaceUp = true
            firstSelectedIndex = index
            return false
        } else {
            card.isFaceUp = true
            val firstCard = cards[firstIndex]

            return if (firstCard.content == card.content) {
                markAsMatched(firstCard, card)
                true
            } else {
                firstSelectedIndex = null
                false
            }
        }
    }

    private fun markAsMatched(card1: WellnessMemoryCard, card2: WellnessMemoryCard) {
        card1.isMatched = true
        card2.isMatched = true
        firstSelectedIndex = null
        checkWin()
    }

    private fun checkWin() {
        if (cards.all { it.isMatched }) {
            isGameOver = true
        }
    }

    /**
     * Updates the game timer. Should be called every second.
     */
    fun updateTimer() {
        if (secondsRemaining > 0 && !isGameOver) {
            secondsRemaining -= 1
        } else if (secondsRemaining == 0) {
            isGameOver = true
        }
    }

    fun getMatchedPairsCount(): Int = cards.count { it.isMatched } / 2
    fun getTotalPairsCount(): Int = emojis.size

    /**
     * Resets the visual state of unmatched cards.
     */
    fun clearNonMatchedCards() {
        cards.forEach { if (!it.isMatched) it.isFaceUp = false }
        firstSelectedIndex = null
    }
}