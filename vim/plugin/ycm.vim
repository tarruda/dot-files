if exists("g:loaded_ycm") || !has('neovim')
  finish
endif

let g:loaded_ycm = 1

let g:ycm_allow_changing_updatetime =
      \ get( g:, 'ycm_allow_changing_updatetime', 1 )

let g:ycm_open_loclist_on_ycm_diags =
      \ get( g:, 'ycm_open_loclist_on_ycm_diags', 1 )

let g:ycm_add_preview_to_completeopt =
      \ get( g:, 'ycm_add_preview_to_completeopt', 0 )

let g:ycm_autoclose_preview_window_after_completion =
      \ get( g:, 'ycm_autoclose_preview_window_after_completion', 0 )

let g:ycm_autoclose_preview_window_after_insertion =
      \ get( g:, 'ycm_autoclose_preview_window_after_insertion', 0 )

let g:ycm_key_list_select_completion =
      \ get( g:, 'ycm_key_list_select_completion', ['<TAB>', '<Down>'] )

let g:ycm_key_list_previous_completion =
      \ get( g:, 'ycm_key_list_previous_completion', ['<S-TAB>', '<Up>'] )

let g:ycm_key_invoke_completion =
      \ get( g:, 'ycm_key_invoke_completion', '<C-Space>' )

let g:ycm_key_detailed_diagnostics =
      \ get( g:, 'ycm_key_detailed_diagnostics', '<leader>d' )

let g:ycm_key_compile =
      \ get( g:, 'ycm_key_compile', '<c-d>' )

let g:ycm_cache_omnifunc =
      \ get( g:, 'ycm_cache_omnifunc', 1 )

let g:ycm_server_use_vim_stdout =
      \ get( g:, 'ycm_server_use_vim_stdout', 0 )

let g:ycm_server_log_level =
      \ get( g:, 'ycm_server_log_level', 'info' )

let g:ycm_server_keep_logfiles =
      \ get( g:, 'ycm_server_keep_logfiles', 0 )

let g:ycm_extra_conf_vim_data =
      \ get( g:, 'ycm_extra_conf_vim_data', [] )

let g:ycm_path_to_python_interpreter =
      \ get( g:, 'ycm_path_to_python_interpreter', '' )

let g:ycm_show_diagnostics_ui =
      \ get( g:, 'ycm_show_diagnostics_ui',
      \ get( g:, 'ycm_register_as_syntastic_checker', 1 ) )

let g:ycm_enable_diagnostic_signs =
      \ get( g:, 'ycm_enable_diagnostic_signs',
      \ get( g:, 'syntastic_enable_signs', 1 ) )

let g:ycm_enable_diagnostic_highlighting =
      \ get( g:, 'ycm_enable_diagnostic_highlighting',
      \ get( g:, 'syntastic_enable_highlighting', 1 ) )

let g:ycm_echo_current_diagnostic =
      \ get( g:, 'ycm_echo_current_diagnostic',
      \ get( g:, 'syntastic_echo_current_error', 1 ) )

let g:ycm_always_populate_location_list =
      \ get( g:, 'ycm_always_populate_location_list',
      \ get( g:, 'syntastic_always_populate_loc_list', 0 ) )

let g:ycm_error_symbol =
      \ get( g:, 'ycm_error_symbol',
      \ get( g:, 'syntastic_error_symbol', '>>' ) )

let g:ycm_warning_symbol =
      \ get( g:, 'ycm_warning_symbol',
      \ get( g:, 'syntastic_warning_symbol', '>>' ) )

let g:ycm_goto_buffer_command =
      \ get( g:, 'ycm_goto_buffer_command', 'same-buffer' )


augroup ycmStart
  autocmd!
  autocmd VimEnter * call ycm#StartYcmd()
augroup END

