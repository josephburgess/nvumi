# nvumi

**nvumi** is a Neovim plugin that integrates the [numi](https://github.com/nikolaeu/numi) natural language calculator with [Snacks.nvim's](https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md) scratch buffer. It lets you type out natural language expressions and see the results inline.

<p align="center">
  <img src="https://github.com/user-attachments/assets/d330a0f8-ccb5-44f3-b1b9-a2775dda72e5" alt="Gif" />
</p>

## Installation

### Using Lazy.nvim

```lua
{
  "josephburgess/nvumi",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    virtual_text = "newline", -- or "inline"
    keys = {
      run = "<CR>", -- run calculations
      reset = "R", -- reset buffer
    },
  }
}
```

## Usage

1. Run the command `:Nvumi` to open a scratch buffer ready for calculations

2. Type your natural language expression(s) (e.g., `20 inches in cm`) in insert mode

3. Press `<CR>` (Enter) in normal mode and the buffer will attempt to evaluate all non-empty, non-commented lines at once

4. Running the command `:help nvumi` opens the manual

## Variable Assignment

nvumi now supports variable assignment, allowing you to store specific numbers, or evaluated results and reuse them in later calculations.
<p align="center">
  <img src="https://github.com/user-attachments/assets/ea3c06ed-2555-45b3-85bb-89e4834f9d97" alt="Variable Assignment Screenshot" width="800" />
</p>

**How It Works:**

- **Assigning a Variable:**
  In your scratch buffer, type an assignment in the format:

  ```text
  variable_name = expression
  ```

  You can assign a variable either to a numerical value or to an evaluated expression, for example:

  ```text
  x = 20 inches in cm
  y = 5000
  ```

  In the first example, nvumi evaluates the expression (`20 inches in cm`) and stores its result in the variable `x`.
  In the second, `y` simply holds the number `5000` without any further evaluation.

- **Using Variables in Expressions:**
  Once assigned, you can reference variables in other calculations:

  ```text
  x * y
  x + 5
  y meters in kilometers
  ```

  nvumi will substitute the variable with its stored value before evaluation.

- **Resetting Variables:**
  Using the `<reset>` command clears both the buffer and all stored variables.

💡 _Tip:_ Variable names must start with a letter or underscore, followed by letters, numbers, or underscores.

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

## Planned Features & Roadmap

A few things I'm thinking about adding as I continue trying to expand my knowledge of `lua` and plugin development:

- [x] Assigning answers to variables
- [ ] Auto-evaluate expressions as you type
- [ ] Yankable answers!
- [ ] Ability to call numi/evaluate expressions anywhere (not just in the scratch buffer)
- [ ] Fine-tuning dates, times, and unit formatting
- [ ] Custom prefixes/suffixes for results (e.g., `=, →` etc).
- [ ] Additional conversions not currently possible with numi (possibly live prices for currency etc)

## License

MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgements

- **[Snacks.nvim](https://github.com/folke/snacks.nvim):**
  Folke needs no introduction given his super-human contributions to the community. The `lua` code runner built into the Scratch buffer inspired this idea in the first place.
- **[numi](https://github.com/nikolaeu/numi):**
  Thanks for providing an amazing natural language calculator.
