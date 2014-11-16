call rpc#plugin#Register('python', expand('<sfile>:p:h').'/nvim_snake.py', [
      \ ['command', 'command:SnakeStart', 1, 'SnakeStart', {}],
      \ ])
