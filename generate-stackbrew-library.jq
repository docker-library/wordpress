"apache" as $defaultVariant
| .latest as $latest
| (
	if ($ARGS.positional | length) > 0 then
		$ARGS.positional[]
	else
		# the order of "versions.json" is the order of our output (see "versions.sh")
		keys_unsorted[]
	end
) as $name
| (.[$name] // error("unknown version: \($name)"))

# "beta" channel even with release, skip it
| select($name != "beta" or .version != $latest.version)

| .phpDefault as $phpDefault

# "7.1.5" -> [ "7.1.5", "7.1", "7", "latest" ]
# cli "2.12.0" -> [ "cli-2.12.0", "cli-2.12", "cli-2", "cli" ]
| (
	[
		.version
		# WordPress releases the first of a series as "X.Y" (there is no "X.Y.0" tarball), but we want our tags to include "X.Y.0" too
		| if test("^[0-9]+[.][0-9]+$") then
			. + ".0"
		else . end
		| recurse(
			if test("[.-]") then
				sub("[.-][^.-]*$"; "")
			else empty end
		)
	]
	+ [ "latest" ]
	# the release name is a prefix on everything, and replaces "latest" (so "beta-latest" is just "beta")
	| if $name != "latest" then
		map(if . == "latest" then $name else "\($name)-\(.)" end)
	else . end
) as $aliases

| .php
| to_entries[]
| .key as $phpVersion
| ("php" + $phpVersion) as $phpName
| .value.variants
| to_entries[]
| .key as $variant
| .value

# the suffix on our tags that mirrors the "php" image tag for this exact variant (apache + trixie = "apache-trixie", fpm-alpine + alpine3.24 = "fpm-alpine3.24")
| (($variant | sub("-alpine$"; "")) + "-" + .suite) as $variantSuite

| (
	# each alias with a suffix: "latest" -> "X", other -> "X-SUFFIX" (and "latest" is a special case, so "latest" + "php8.5" is just "php8.5")
	def aliases_with_suffix($suffix):
		$aliases[]
		| if . == "latest" then
			$suffix
		else
			"\(.)-\($suffix)"
		end
	;

	if $name != "cli" then
		[
			if $phpVersion == $phpDefault then
				aliases_with_suffix($variant),

				if $variant == $defaultVariant then
					$aliases[]
				else empty end,

				empty
			else empty end,

			aliases_with_suffix("\($phpName)-\($variant)"),

			if $variant == $defaultVariant then
				aliases_with_suffix($phpName)
			else empty end,

			if $phpVersion == $phpDefault then
				aliases_with_suffix($variantSuite)
			else empty end,

			aliases_with_suffix("\($phpName)-\($variantSuite)"),

			empty
		]
	else
		[
			if $phpVersion == $phpDefault then
				$aliases[]
			else empty end,

			aliases_with_suffix($phpName),

			# "cli" gets only the exact suite ("alpine3.24")
			if $phpVersion == $phpDefault then
				aliases_with_suffix(.suite)
			else empty end,

			aliases_with_suffix("\($phpName)-\(.suite)"),

			empty
		]
	end
) as $tags

| "",
"Tags: \($tags | join(", "))",
"Architectures: \(.arches | join(", "))",
if .constraints then
	"Constraints: \(.constraints | join(", "))"
else empty end,
"Directory: \($name)/\($phpName)/\($variant)",
empty
