package org.iremia.iremia.ui.journal

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import org.iremia.iremia.controller.NotesController
import org.iremia.iremia.controller.NotesState
import org.iremia.iremia.domain.note.EpisodeDraft

/**
 * ViewModel for the Journal Screen.
 *
 * Wraps the [NotesController] and exposes its state to the Compose UI.
 * Handles adding and deleting notes via the controller.
 */
class JournalViewModel(
    private val notesController: NotesController
) : ViewModel() {

    /**
     * Expose the controller state as a Compose-friendly StateFlow.
     */
    val state: StateFlow<NotesState> = notesController.state

    /**
     * Add a new note.
     */
    fun addNote(content: String) {
        viewModelScope.launch {
            notesController.add(content, System.currentTimeMillis())
        }
    }

    /**
     * Add a full episode with the metadata captured by the wizard.
     */
    fun addEpisode(draft: EpisodeDraft) {
        viewModelScope.launch {
            notesController.addEpisode(
                content = draft.content,
                // Use the date+time the user picked; fall back to now if unset.
                createdAt = draft.createdAt ?: System.currentTimeMillis(),
                strength = draft.strength,
                places = draft.places,
                activities = draft.activities,
                bodySignals = draft.bodySignals,
                moodBefore = draft.moodBefore,
                moodAfter = draft.moodAfter,
            )
        }
    }

    /**
     * Update an existing episode with edited content and metadata.
     */
    fun updateEpisode(id: Long, draft: EpisodeDraft) {
        viewModelScope.launch {
            notesController.updateEpisode(
                id = id,
                content = draft.content,
                strength = draft.strength,
                places = draft.places,
                activities = draft.activities,
                bodySignals = draft.bodySignals,
                moodBefore = draft.moodBefore,
                moodAfter = draft.moodAfter,
            )
        }
    }

    /**
     * Delete an existing note.
     */
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
