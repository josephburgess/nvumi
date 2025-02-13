# nvumi

**nvumi** is a Neovim plugin that integrates the [numi](https://github.com/nikolaeu/numi) natural language calculator with [Snacks.nvim's](https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md) scratch buffer. It lets you type out natural language expressions and see the results inline.

![Screenshot 2025-02-13 at 16 26 04](https://github.com/user-attachments/assets/db676c0f-e191-43ad-8c14-909e3ce7302d)



## Installation

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
   Run the command `:Nvumi` to open a scratch buffer ready for calculations

2. **Enter Your Calculation:**
   In the scratch buffer, type your natural language expression (e.g., `20 inches in cm`) in insert mode.

3. **Evaluate the Expression:**
   Press `<CR>` (Enter) on the line you wish to evaluate, the answer will be displayed in virtual text.

## Configuration

TBC

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
