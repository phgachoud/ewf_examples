note
	description: "Summary description for {APPLICATION}."
	date: "$Date: 2013-06-12 08:55:42 -0300 (mié 12 de jun de 2013) $"
	revision: "$Revision: 36 $"

class
	APPLICATION

inherit
	APP_SERVICE
		redefine
			initialize
		end

create
	make_and_launch

feature {NONE} -- Initialization

	initialize
			-- Initialize current service.
		do
			initialize_launcher_nature
			if is_standalone then
				set_service_option ("port", 9090)
				set_service_option ("verbose", True)
			end
			Precursor
		end

	initialize_launcher_nature
			-- Initialize the launcher nature
			-- either cgi, libfcgi, or standalone.
			--| We could extend with more connector if needed.
			--| and we could use WSF_DEFAULT_SERVICE_LAUNCHER to configure this at compilation time.
		local
			p: PATH
			l_entry_name: READABLE_STRING_32
		do
			create p.make_from_string (execution_environment.arguments.command_name)
			if attached p.entry as l_entry then
				l_entry_name := l_entry.name
				if attached l_entry.extension as l_extension then
					l_entry_name := l_entry_name.substring (1, l_entry_name.count - l_extension.count - 1)
				end
				if l_entry_name.ends_with_general ("-cgi") then
					is_cgi := True
				elseif l_entry_name.ends_with_general ("-libfcgi") then
					is_libfcgi := True
				end
			end
			is_standalone := not (is_cgi or is_libfcgi)
		end

feature {NONE} -- Launcher

	is_standalone: BOOLEAN

	is_cgi: BOOLEAN

	is_libfcgi: BOOLEAN

	launch (opts: detachable WSF_SERVICE_LAUNCHER_OPTIONS)
		local
			launcher: WSF_SERVICE_LAUNCHER [APP_SERVICE_EXECUTION]
		do
			if is_cgi then
				create {WSF_CGI_SERVICE_LAUNCHER [APP_SERVICE_EXECUTION]} launcher.make_and_launch (opts)
			elseif is_libfcgi then
				create {WSF_LIBFCGI_SERVICE_LAUNCHER [APP_SERVICE_EXECUTION]} launcher.make_and_launch (opts)
			else
				create {WSF_STANDALONE_SERVICE_LAUNCHER [APP_SERVICE_EXECUTION]} launcher.make_and_launch (opts)
			end
		end


end
