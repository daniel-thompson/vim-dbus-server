" dbus-server.vim - An alternative vim server using DBus
" Daniel Thompson <daniel@redfelineninja.org.uk>

function! StartDBusServer()
python << endpython
import vim
import pydbus
import thread
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
			vim.command(cmd.strip())
			vim.command('redir END')
			result = str(vim.eval('@a'))
		except Exception, e:
			result = 'FAILED: ' + str(e)
		return result

	def Eval(self, expr):
		'''Evaluate expr as a vim expression'''
		try:
			result = vim.eval(expr.strip())
		except Exception, e:
			result = 'FAILED: ' + str(e)
		return result

bus = pydbus.SessionBus()
if 'org.vim.server' not in bus.dbus.ListNames():
	service = bus.publish('org.vim.server', DBusServer())
	loop = GLib.MainLoop()
	thread.start_new_thread(loop.run, ())
endpython
endfunction

function! StopDBusServer()
python << endpython
service.unpublish()
loop.quit()
endpython
endfunction

if !has('python')
	echo "vim-dbus-server requires python support."
else
	if !exists("g:dbus_autostart") || g:dbus_autostart != 0
		if !has("gui_running")
			autocmd VimEnter * call StartDBusServer()
		endif
	endif
endif
