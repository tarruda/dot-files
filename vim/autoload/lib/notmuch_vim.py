import vim, notmuch, re
from datetime import datetime

db = notmuch.Database()
sender_pattern = re.compile(r'^(?:(.*)\s*)?<(.+)@.+>$')

folders = [
        {'name': 'inbox', 'query': 'tag:inbox'},
        {'name': 'starred', 'query': 'tag:flagged'},
        {'name': 'draft', 'query': 'tag:draft'},
        {'name': 'trash', 'query': 'tag:deleted'},
        ]

def format_messages(messages):
    rv = []
    for msg in messages:
        date = datetime.fromtimestamp(msg.get_date()).strftime('%Y-%m-%d')
        sender = msg.get_header('from')
        match = sender_pattern.match(sender)
        if match:
            if match.group(1):
                sender = match.group(1)
            else:
                sender = match.group(2)
        sender = sender.ljust(20)[0:20]
        subject = msg.get_header('subject')
        rv.append('%s    %s    %s' % (date, sender, subject,))
    return rv

def render_folders():
    buf = vim.current.buffer
    buf[0] = 'Default mailboxes'
    for folder in folders:
        query = db.create_query(folder['query'])
        count = len(query.search_threads())
        buf.append("  %s (%d)" % (folder['name'], count,))

def render_threads():
    buf = vim.current.buffer
    query = db.create_query(folders[0]['query'])
    query.set_sort(notmuch.Query.SORT.NEWEST_FIRST)
    del buf[0:-1]
    buf[0] = "q:Quit  d:Del  u:Undel  s:Save  m:Mail  r:Reply  R:Group  ?:Help"
    for thread in query.search_threads():
        toplevel = thread.get_toplevel_messages()
        for msg in format_messages(toplevel):
            buf.append(msg.encode('utf-8'))
