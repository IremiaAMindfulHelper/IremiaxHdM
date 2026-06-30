package org.iremia.iremia.ui.journal

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import org.iremia.iremia.controller.NotesController
import org.iremia.iremia.controller.NotesState

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
