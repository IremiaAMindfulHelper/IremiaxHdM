package org.iremia.iremia.ui.journal

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import org.iremia.iremia.controller.NotesController
import org.iremia.iremia.controller.NotesState
import org.iremia.iremia.data.garden.PlantResult
import org.iremia.iremia.domain.note.EpisodeDraft

/**
 * ViewModel for the Journal Screen.
 *
 * Wraps the [NotesController] and exposes its state to the Compose UI.
 * Adds and updates entries through the type-aware draft path so both panic and
 * journal entries flow through a single code path.
 */
class JournalViewModel(
    private val notesController: NotesController
) : ViewModel() {

    /** Expose the controller state as a Compose-friendly StateFlow. */
    val state: StateFlow<NotesState> = notesController.state

    // The result of the most recent plant attempt, so the saved screen can tell
    // whether a new plant was set or the day already had this type (Block 3 / 6.2).
    private val _lastPlantResult = MutableStateFlow<PlantResult?>(null)
    val lastPlantResult: StateFlow<PlantResult?> = _lastPlantResult.asStateFlow()

    /**
     * Add an entry (panic or journal) from the draft captured by the wizard and
     * plant a linked garden item. Publishes the [PlantResult] for the saved screen.
     */
    fun addEntry(draft: EpisodeDraft) {
        viewModelScope.launch {
            _lastPlantResult.value = notesController.addDraft(draft)
        }
    }

    /** Reset the plant result when a new capture flow starts. */
    fun clearPlantResult() {
        _lastPlantResult.value = null
    }

    /** Update an existing entry with edited content and metadata. */
    fun updateEntry(id: Long, draft: EpisodeDraft) {
        viewModelScope.launch {
            notesController.updateDraft(id, draft)
        }
    }

    /** Delete an existing entry. */
    fun deleteNote(id: Long) {
        viewModelScope.launch {
            notesController.delete(id)
        }
    }

    override fun onCleared() {
        super.onCleared()
        notesController.clear()
    }
}
