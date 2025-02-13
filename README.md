# nvumi

**nvumi** is a Neovim plugin that integrates the [numi](https://github.com/nikolaeu/numi) natural language calculator with [Snacks.nvim's](https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md) scratch buffer. It lets you type out natural language expressions and see the results inline.


<p align="center">
  <img src="https://github.com/user-attachments/assets/cab9e513-cbce-40fb-b82f-0be6371cddba" alt="Gif" />
</p>


## Installation

### Using Lazy.nvim

```lua
{
  "josephburgess/nvumi",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    virtual_text = "inline" -- or "newline"
  }
}
```

## Usage

1. **Open the nvumi scratch buffer:**
   Run the command `:Nvumi` to open a scratch buffer ready for calculations

2. **Enter Your Calculation:**
   In the scratch buffer, type your natural language expression (e.g., `20 inches in cm`) in insert mode.

3. **Evaluate:**
   Press `<CR>` (Enter) and the buffer will attempt to evaluate all non-empty lines

## Configuration

Currently you can configure where you want the virtual text to be displayed, `inline` or `newline`:

<details closed>
  <summary>Inline</summary>
  <p>
    <img src="https://github.com/user-attachments/assets/dae054cc-bddb-49c2-802a-68bfc9108d49" alt="Inline Screenshot" />
  </p>
</details>

<details closed>
  <summary>Newline</summary>
  <p>
    <img src="https://github.com/user-attachments/assets/f7222430-4cb4-4eb7-a155-477d70dc39ff" alt="Newline Screenshot" />
  </p>
</details>

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
  Used to create the scratch buffer

## Contributing

This is my first attempt at a Neovim plugin, so contributions are more than welcome! If you encounter issues or have ideas for improvements, please open an issue or submit a pull request on GitHub.

## License

MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgements

- **[Snacks.nvim](https://github.com/folke/snacks.nvim):**
  Folke needs no introduction given his super-human contributions to the community. The `lua` code runner built into the Scratch buffer inspired this idea in the first place.
- **[numi](https://github.com/nikolaeu/numi):**
  Thanks for providing an amazing natural language calculator.
