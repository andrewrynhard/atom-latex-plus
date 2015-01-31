module.exports =
class ProcessManager

  constructor: ->
    @PATH = switch process.platform
      when 'win32'
        process.env[Path]
      when 'darwin'
        process.env.PATH

    @texPath = atom.config.get('texlicious.texPath') ? '/usr/texbin'
    #TODO: Get the users TEXINPUTS if they are defined in process.env.
    @texInputs = atom.config.get('texlicious.texInputs') ? ''

  options: () ->
    environment = process.env
    environment.PATH =  @PATH + ':' + @texPath + ':'
    environment.TEXINPUTS = @texInputs + '//:' if @texInputs?
    environment.timeout = 60000

    environment

  # kill: (pid) ->
  #   unless pid?
  #     console.log "No pid to kill."
  #   else
  #     try
  #       process.kill(pid, 'SIGINT')
  #     catch e
  #       if e.code is 'ESRCH'
  #         throw new Error("Process #{pid} has already been killed.")
  #       else
  #         throw (e)
