require('project_nvim').setup({
    patterns = {
        '.git',
        'package.json',
        '.terraform',
        'go.mod',
        'requirements.txt',
        'requirements.yml',
        'pyrightconfig.json',
        'pyproject.toml',
        'Cargo.toml',
    },
    -- detection_methods = { "lsp", "pattern" },
    detection_methods = { 'pattern' },
})
