# nvumi

**nvumi** is a Neovim plugin that integrates the [numi](https://github.com/nikolaeu/numi) natural language calculator with [Snacks.nvim's](https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md) scratch buffer. It lets you type out natural language expressions and see the results inline.

![Screenshot 2025-02-13 at 11 48 41@2x](https://github.com/user-attachments/assets/a3f1b682-f8a2-4aef-b745-5f9f74096846)


## Installation

You will need numi-cli installed:

```
curl -sSL https://s.numi.app/cli | sh
```

### Using Lazy.nvim

```lua
{
  "josephburgess/nvumi",
  dependencies = { "folke/snacks.nvim" },
  opts = {}
}
```

## Usage

1. **Open the nvumi scratch buffer:**
   Run the command `:NVumi` to open a scratch buffer ready for calculations

2. **Enter Your Calculation:**
   In the scratch buffer, type your natural language expression (e.g., `20 inches in cm`) in insert mode.

3. **Evaluate the Expression:**
   Press `<CR>` (Enter) on the line you wish to evaluate, the answer will be displayed in virtual text.

## Configuration

TBC

## How It Works

nvumi leverages the `numi-cli` tool to evaluate your natural language expressions. When you press `<CR>` in a scratch buffer:

1. nvumi reads the current line of text.
2. It calls `numi-cli` with the expression.
3. The result is then displayed inline as virtual text at the end of the evaluated line.

## Requirements

- **[numi-cli](https://github.com/nikolaeu/numi):**
  Install it using:

  ```bash
  curl -sSL https://s.numi.app/cli | sh
  ```

  Or with [Homebrew](https://brew.sh/):

  ```bash
  brew install nikolaeu/numi/numi-cli
  ```

- **[folke/snacks.nvim](https://github.com/folke/snacks.nvim):**
  This plugin is used to create and manage persistent scratch buffers.

## Contributing

This is my first attempt at a Neovim plugin, so contributions are more than welcome! If you encounter issues or have ideas for improvements, please open an issue or submit a pull request on GitHub.

## License

MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgements

- **[numi](https://github.com/nikolaeu/numi):**
  Thanks for providing an amazing natural language calculator.
- **[Snacks.nvim](https://github.com/folke/snacks.nvim):**
  Folke needs no introduction given his super-human contributions to the community over the years. The lua code runner built into the Scratch buffer inspired this idea in the first place.
