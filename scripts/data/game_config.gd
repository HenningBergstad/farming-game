extends Node

# --- Crop paths ---
const CROP_PATHS: Array = [
	"res://resources/crops/corn.tres",
	"res://resources/crops/oats.tres",
	"res://resources/crops/carrot.tres",
	"res://resources/crops/potato.tres",
	"res://resources/crops/raddish.tres",
	"res://resources/crops/lettuce.tres",
	"res://resources/crops/alfalfa.tres",
	"res://resources/crops/clover.tres",
]

# --- Gold ---
const STARTING_GOLD: int = 50

# --- Turn values ----
const TURN_DURATION: float = 6.0          # default 8
const TURN_DURATION_PADDING: float = 0.2  # default 0.5

# --- Market ---
const MARKET_FREEZE: int = 4
const MARKET_RECOVERY_RATE: float = 0.1
const MARKET_SATURATION_HIT: float = 0.2
const MIN_SELL_PRICE: int = 1
