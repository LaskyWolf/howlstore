//! The store's folders (organisation and application both "HowlStore"). `move_from_woofstore` brings over what the
//! store kept under its old name, WoofStore.

use std::env;
use std::fs;
use std::path::{Path, PathBuf};

fn xdg(variable: &str, fallback: &str) -> PathBuf {
    env::var_os(variable)
        .map(PathBuf::from)
        .filter(|path| path.is_absolute())
        .unwrap_or_else(|| PathBuf::from(env::var_os("HOME").unwrap_or_default()).join(fallback))
}

/// `~/.local/share`: imported AppImages and their launchers live below it.
pub fn data_home() -> PathBuf {
    xdg("XDG_DATA_HOME", ".local/share")
}

/// `~/.local/share/HowlStore/HowlStore`: job folders and the askpass helper.
pub fn app_data() -> PathBuf {
    data_home().join("HowlStore/HowlStore")
}

/// `~/.cache/HowlStore/HowlStore`: downloaded lists and web answers.
pub fn cache() -> PathBuf {
    xdg("XDG_CACHE_HOME", ".cache").join("HowlStore/HowlStore")
}

/// `~/.config/HowlStore/HowlStore.conf` is the settings file.
pub fn config() -> PathBuf {
    xdg("XDG_CONFIG_HOME", ".config").join("HowlStore")
}

pub fn home() -> PathBuf {
    PathBuf::from(env::var_os("HOME").unwrap_or_default())
}

/// Moves WoofStore's settings, caches, job folders, imported AppImages and their launchers to HowlStore's names, and
/// points mimeapps.list at the renamed launchers. Each part moves only while HowlStore has none of its own, so it runs
/// once and never overwrites.
pub fn move_from_woofstore() {
    move_old_files(&xdg("XDG_CONFIG_HOME", ".config"), &data_home(), &xdg("XDG_CACHE_HOME", ".cache"));
}

fn move_old_files(config_home: &Path, data_home: &Path, cache_home: &Path) -> bool {
    let mut moved = false;
    // The folder, then the file or folder inside it that also carries the application name
    for (home, inner) in [(config_home, "WoofStore.conf"), (data_home, "WoofStore"), (cache_home, "WoofStore")] {
        let (old, new) = (home.join("WoofStore"), home.join("HowlStore"));
        if old.is_dir() && !new.exists() && fs::rename(&old, &new).is_ok() {
            moved = true;
            let renamed = inner.replace("WoofStore", "HowlStore");
            if !new.join(&renamed).exists() {
                let _ = fs::rename(new.join(inner), new.join(renamed));
            }
        }
    }
    // AppImage launchers: new name, and their paths point into the moved folder
    let Ok(entries) = fs::read_dir(data_home.join("applications")) else { return moved };
    for entry in entries.flatten() {
        let name = entry.file_name().to_string_lossy().into_owned();
        let Some(id) = name.strip_prefix("woof-store-").and_then(|rest| rest.strip_suffix(".desktop")) else { continue };
        let new = entry.path().with_file_name(format!("howl-store-{id}.desktop"));
        let Ok(text) = fs::read_to_string(entry.path()) else { continue };
        let text = text.replace("/WoofStore/appimages/", "/HowlStore/appimages/").replace("X-WoofStore-AppImage=", "X-HowlStore-AppImage=");
        if !new.exists() && fs::write(&new, text).is_ok() && fs::remove_file(entry.path()).is_ok() {
            moved = true;
        }
    }
    // Links and files that opened in WoofStore or in one of its AppImages open in the renamed launchers
    let mime = config_home.join("mimeapps.list");
    if let Ok(text) = fs::read_to_string(&mime) {
        let renamed = text.replace("io.github.laskywolf.WoofStore.desktop", "io.github.laskywolf.HowlStore.desktop").replace("woof-store-", "howl-store-");
        if renamed != text && fs::write(&mime, renamed).is_ok() {
            moved = true;
        }
    }
    moved
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn woofstore_files_move_once_and_never_overwrite() {
        let root = tempfile::tempdir().unwrap();
        let (config, data, cache) = (root.path().join("config"), root.path().join("data"), root.path().join("cache"));
        let write = |path: PathBuf, text: &str| {
            fs::create_dir_all(path.parent().unwrap()).unwrap();
            fs::write(path, text).unwrap();
        };
        write(config.join("WoofStore/WoofStore.conf"), "[General]\nupdateAur=false\n");
        write(data.join("WoofStore/appimages/abc.AppImage"), "elf");
        write(data.join("WoofStore/WoofStore/jobs/1/log"), "done");
        write(cache.join("WoofStore/WoofStore/news.json"), "[]");
        let launcher = "[Desktop Entry]\nExec=\"/home/me/.local/share/WoofStore/appimages/abc.AppImage\"\nX-WoofStore-AppImage=abc\n";
        write(data.join("applications/woof-store-abc.desktop"), launcher);
        write(data.join("applications/org.kde.krita.desktop"), "other");
        write(
            config.join("mimeapps.list"),
            "[Default Applications]\nx-scheme-handler/appstream=io.github.laskywolf.WoofStore.desktop\nx-scheme-handler/curseforge=woof-store-abc.desktop\n",
        );

        assert!(move_old_files(&config, &data, &cache));
        assert_eq!(fs::read_to_string(config.join("HowlStore/HowlStore.conf")).unwrap(), "[General]\nupdateAur=false\n");
        assert!(data.join("HowlStore/appimages/abc.AppImage").is_file() && data.join("HowlStore/HowlStore/jobs/1/log").is_file());
        assert!(cache.join("HowlStore/HowlStore/news.json").is_file() && !config.join("WoofStore").exists());
        assert_eq!(
            fs::read_to_string(data.join("applications/howl-store-abc.desktop")).unwrap(),
            "[Desktop Entry]\nExec=\"/home/me/.local/share/HowlStore/appimages/abc.AppImage\"\nX-HowlStore-AppImage=abc\n"
        );
        assert!(!data.join("applications/woof-store-abc.desktop").exists() && data.join("applications/org.kde.krita.desktop").exists());
        assert_eq!(
            fs::read_to_string(config.join("mimeapps.list")).unwrap(),
            "[Default Applications]\nx-scheme-handler/appstream=io.github.laskywolf.HowlStore.desktop\nx-scheme-handler/curseforge=howl-store-abc.desktop\n"
        );

        // A WoofStore folder that turns up again (the old store saved its settings on the way out) leaves HowlStore's alone
        write(config.join("WoofStore/WoofStore.conf"), "late");
        assert!(!move_old_files(&config, &data, &cache));
        assert!(config.join("WoofStore/WoofStore.conf").exists() && !fs::read_to_string(config.join("HowlStore/HowlStore.conf")).unwrap().contains("late"));
    }
}
