package org.iremia.iremia.viewModels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import org.iremia.iremia.controller.MantrasController
import org.iremia.iremia.controller.MantrasState

class MantrasViewModel(private val controller: MantrasController) : ViewModel() {
    val state: StateFlow<MantrasState> = controller.state

    fun add(text: String)   = viewModelScope.launch { controller.add(text) }
    fun remove(id: Long)    = viewModelScope.launch { controller.remove(id) }

    override fun onCleared() {
        controller.clear()
        super.onCleared()
    }
}