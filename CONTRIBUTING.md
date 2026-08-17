# Contributing to Omado

Thanks for contributing to Omado, a minimal todo-list bar widget for Omarchy.

## Before You Start

- Check open issues before starting larger changes.
- For new features or behavior changes, open an issue first so the approach can be discussed.
- Keep changes focused. Avoid unrelated formatting or refactoring.

## Local Setup

Omado runs as an Omarchy Quickshell plugin. Install Omarchy and clone the plugin into its plugin directory:

```sh
git clone https://github.com/Maduki-tech/Omado ~/.config/omarchy/plugins/maduki-tech.omado
omarchy plugin enable maduki-tech.omado
```

After making changes, reload or restart the Omarchy shell so Quickshell loads updated QML and JavaScript files.

## Testing Changes

This project currently has no automated test suite. Test changes manually in a running Omarchy session:

- Enable the plugin and confirm the bar widget loads without shell errors.
- Open and close the todo panel from the bar.
- Add a task, including submitting with Enter and rejecting blank input.
- Toggle, edit, and remove tasks.
- Clear completed tasks.
- Restart or reload the shell and confirm tasks persist.
- Confirm keyboard behavior: Escape closes the panel and Tab switches panels.
- Check the widget at the bar positions and display sizes relevant to your setup.

Before submitting, inspect the Quickshell logs for QML warnings or runtime errors.

## Code Guidelines

- Follow the existing QML and JavaScript style.
- Use Omarchy and Quickshell APIs already used by the project instead of adding dependencies.
- Keep task data local. Do not add accounts, network calls, telemetry, or remote storage without prior discussion.
- Preserve the existing state-file format unless the change includes a migration plan.
- Keep user-visible behavior keyboard-friendly and accessible.
- Update `README.md` when installation, requirements, or user-facing behavior changes.

## Pull Requests

Pull requests should include:

- A short description of the problem and solution.
- Manual testing steps and environment details.
- Screenshots or a short recording for visual changes.
- Notes about changes to saved task data, if applicable.
- Any known limitations or follow-up work.

Use a clear, imperative commit subject, for example:

```text
Add keyboard shortcut for clearing completed tasks
```

Reviewers should be able to run the plugin from the documented installation instructions and reproduce the validation steps.

## Reporting Issues

Include your Omarchy and Quickshell versions, reproduction steps, expected behavior, actual behavior, and relevant log output. Remove personal information from logs before posting them.

## License

By contributing, you agree that your contributions are provided under the project's [MIT License](LICENSE).
