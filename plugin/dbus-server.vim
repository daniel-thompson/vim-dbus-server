" dbus-server.vim - An alternative vim server using DBus
" Daniel Thompson <daniel@redfelineninja.org.uk>

function! StartDBusServer()
python3 << endpython
import vim
import pydbus
import threading
from gi.repository import GLib

class DBusServer(object):
	'''
	<node>
	  <interface name='org.vim.server'>
	    <method name='Command'>
	      <arg type='s' name='a' direction='in'/>
	      <arg type='s' name='response' direction='out'/>
	    </method>
	    <method name='Eval'>
	      <arg type='s' name='a' direction='in'/>
	      <arg type='s' name='response' direction='out'/>
	    </method>
	  </interface>
	</node>
	'''

	def Command(self, cmd):
		'''Run cmd as an ex command'''
		try:
			vim.command('redir @a')
			vim.command('silent ' + cmd.strip())
			vim.command('redir END')
			result = str(vim.eval('@a'))
		except Exception as e:
			result = 'FAILED: ' + str(e)
		return result

	def Eval(self, expr):
		'''Evaluate expr as a vim expression'''
		try:
			result = vim.eval(expr.strip())
		except Exception as e:
			result = 'FAILED: ' + str(e)
		return result

bus = pydbus.SessionBus()

prefix = 'org.vim.server.'
tag = vim.eval('g:dbus_servername')
extra_tag = 1

name = prefix + tag
dbus_names = bus.dbus.ListNames()
while name in dbus_names:
	name = prefix + tag + str(extra_tag)
	extra_tag += 1

service = bus.publish(name, DBusServer())
mainloop = GLib.MainLoop()
dbus_thread = threading.Thread(target=mainloop.run, daemon=True)
dbus_thread.start()
endpython
endfunction

function! StopDBusServer()
python3 << endpython
service.unpublish()
mainloop.quit()
endpython
endfunction

if !exists("g:dbus_servername")
	let g:dbus_servername = "GVIM"
endif

if !has('python3')
	echo "vim-dbus-server requires python support."
else
	if !exists("g:dbus_autostart") || g:dbus_autostart != 0
		if !has("gui_running")
			autocmd VimEnter * call StartDBusServer()
		endif
	endif
endif
