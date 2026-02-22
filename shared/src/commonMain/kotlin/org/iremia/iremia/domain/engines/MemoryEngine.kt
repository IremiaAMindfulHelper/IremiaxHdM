package org.iremia.iremia.domain.engines

data class WellnessMemoryCard(
    val id: Int,
    val content: String,
    var isFaceUp: Boolean = false,
    var isMatched: Boolean = false
)

class MemoryEngine {
    private val emojis = listOf("🧠", "☀️", "🌿", "🧘", "💧", "☁️")
    var cards = mutableListOf<WellnessMemoryCard>()
    var firstSelectedIndex: Int? = null
    var secondsRemaining = 60
    var isGameOver = false

    init {
        setupGame()
    }

    fun setupGame() {
        val gameContent = (emojis + emojis).shuffled()
        cards = gameContent.mapIndexed { index, emoji ->
            WellnessMemoryCard(id = index, content = emoji)
        }.toMutableList()
        secondsRemaining = 60
        isGameOver = false
    }

    fun handleSelection(index: Int): Boolean {
        val card = cards[index]
        if (card.isFaceUp || card.isMatched || firstSelectedIndex == index) return false

        // Wenn noch keine Karte umgedreht wurde
        val firstIndex = firstSelectedIndex
        if (firstIndex == null) {
            // Alle nicht gematchten Karten erst mal wieder zudecken
            cards.forEach { if (!it.isMatched) it.isFaceUp = false }
            card.isFaceUp = true
            firstSelectedIndex = index
            return false
        } else {
            // Zweite Karte wird gewählt
            card.isFaceUp = true
            val firstCard = cards[firstIndex]

            if (firstCard.content == card.content) {
                firstCard.isMatched = true
                card.isMatched = true
                firstSelectedIndex = null
                checkWin()
                return true // Match gefunden!
            } else {
                firstSelectedIndex = null
                return false // Kein Match
            }
        }
    }

    private fun checkWin() {
        if (cards.all { it.isMatched }) {
            isGameOver = true
        }
    }

    fun updateTimer() {
        if (secondsRemaining > 0 && !isGameOver) {
            secondsRemaining -= 1
        } else if (secondsRemaining == 0) {
            isGameOver = true
        }
    }

    fun getMatchedPairsCount(): Int = cards.count { it.isMatched } / 2
    fun getTotalPairsCount(): Int = emojis.size
    fun clearNonMatchedCards() {
        cards.forEach { card ->
            if (!card.isMatched) {
                card.isFaceUp = false
            }
        }
        firstSelectedIndex = null
    }
}