
use crate::database::init_database;
use crate::database::properties::property;
use crate::download_thread::DOWNLOAD_AND_EXPORT_TO;
use crate::local::{create_dir_if_not_exists, join_paths};
use once_cell::sync::OnceCell;
use std::sync::Arc;
use lazy_static::lazy_static;
use tokio::sync::Mutex;
use tokio::sync::RwLock;
use crate::anime_home::Client;
use crate::download_thread;

lazy_static! {
    pub(crate) static ref CLIENT: Arc<RwLock<Client>> = Arc::new(RwLock::new(Client::new()));
    static ref INIT_ED: Mutex<bool> = Mutex::new(false);
}

static ROOT: OnceCell<String> = OnceCell::new();
static IMAGE_CACHE_DIR: OnceCell<String> = OnceCell::new();
static DATABASE_DIR: OnceCell<String> = OnceCell::new();
pub(crate) static DOWNLOAD_DIR: OnceCell<String> = OnceCell::new();

pub async fn init_root(path: &str) {
    let mut lock = INIT_ED.lock().await;
    if *lock {
        return;
    }
    *lock = true;
    println!("Init application with root : {}", path);
    ROOT.set(path.to_owned()).unwrap();
    IMAGE_CACHE_DIR
        .set(join_paths(vec![path, "image_cache"]))
        .unwrap();
    DATABASE_DIR
        .set(join_paths(vec![path, "database"]))
        .unwrap();
    DOWNLOAD_DIR
        .set(join_paths(vec![path, "download"]))
        .unwrap();
    create_dir_if_not_exists(ROOT.get().unwrap());
    create_dir_if_not_exists(IMAGE_CACHE_DIR.get().unwrap());
    create_dir_if_not_exists(DATABASE_DIR.get().unwrap());
    create_dir_if_not_exists(DOWNLOAD_DIR.get().unwrap());
    init_database().await;
    *DOWNLOAD_AND_EXPORT_TO.lock().await =
        property::load_property("download_and_export_to".to_owned())
            .await
            .unwrap();
    tokio::spawn(download_thread::start_download());
}

#[allow(dead_code)]
pub(crate) fn get_root() -> &'static String {
    ROOT.get().unwrap()
}

pub(crate) fn get_image_cache_dir() -> &'static String {
    IMAGE_CACHE_DIR.get().unwrap()
}

pub(crate) fn get_database_dir() -> &'static String {
    DATABASE_DIR.get().unwrap()
}
