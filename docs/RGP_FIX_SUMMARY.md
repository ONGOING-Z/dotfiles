# RGP Initial Query Fix

## Problem
The `rgp` command with an initial keyword (e.g., `rgp "keyword"`) was not working properly. The fzf popup would appear with the keyword in the search box, but the search results were not displayed.

## Root Cause
The issue was in the `rgp` function implementation in `/workspace/config/zshrc`. The function was using fzf in `--disabled` mode, which starts with search disabled. When an initial query was provided:
1. The query was set in the fzf search box using `--query "$INITIAL_QUERY"`
2. But no actual search was executed because fzf was in disabled mode
3. The search would only trigger when the user modified the query, triggering the `change` event

## Solution
Modified the `rgp` function to pipe the initial search results directly to fzf when an initial query is provided:

```bash
# Old approach (didn't work):
if [ -n "$INITIAL_QUERY" ]; then
    # Check if results exist but don't use them
    local INITIAL_RESULTS="$($RG_PREFIX -- "$INITIAL_QUERY" 2>/dev/null)"
    # ...
fi
# Then start fzf with empty input
sel="$(FZF_DEFAULT_COMMAND='' fzf-tmux ... --query "$INITIAL_QUERY" ...)"

# New approach (works):
if [ -n "$INITIAL_QUERY" ]; then
    # Execute search and pipe results directly to fzf
    sel="$($RG_PREFIX -- "$INITIAL_QUERY" 2>/dev/null | fzf-tmux ... --query "$INITIAL_QUERY" ...)"
else
    # No initial query: start with empty results
    sel="$(FZF_DEFAULT_COMMAND='' fzf-tmux ...)"
fi
```

## Changes Made
1. Updated the `rgp` function in `/workspace/config/zshrc` (lines 391-434)
2. When an initial query is provided, the function now:
   - Executes the ripgrep search with the initial query
   - Pipes the results directly to fzf
   - Still preserves the query in the fzf search box for further refinement
3. When no initial query is provided, behavior remains unchanged

## Testing
To test the fix:
1. Run `/workspace/test_rgp.sh` for an interactive test
2. Or manually test:
   ```bash
   source /workspace/config/zshrc  # Reload the configuration
   rgp "keyword"                   # Should show search results immediately
   ```

## Impact
- Users can now use `rgp "keyword"` to immediately see search results
- The interactive search experience is preserved
- Performance is maintained with the debounce delay for subsequent searches
