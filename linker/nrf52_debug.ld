/* Linker script to configure memory regions. */

SEARCH_DIR(.)
GROUP(-lgcc -lc)

MEMORY
{
  /** Flash start address for the bootloader. This setting will also be stored in UICR to allow the
   *  MBR to init the bootloader when starting the system. This value must correspond to 
   *  BOOTLOADER_REGION_START found in dfu_types.h. The system is prevented from starting up if 
   *  those values do not match. The check is performed in main.c, see
   *  APP_ERROR_CHECK_BOOL(*((uint32_t *)NRF_UICR_BOOT_START_ADDRESS) == BOOTLOADER_REGION_START);
   */
  FLASH (rx) : ORIGIN = 0x74000-28K, LENGTH = 0x7E000-0x74000+28K /* 40 KB */

  /** Location of mbr params page in flash. */
  MBR_PARAMS_PAGE (rw) : ORIGIN = 0x7E000, LENGTH = 0x1000
  
  /** Location of bootloader setting in flash. */
  BOOTLOADER_SETTINGS (rw) : ORIGIN = 0x7F000, LENGTH = 0x1000



  /** RAM Region for bootloader. */
  RAM (rwx) :  ORIGIN = 0x20008000, LENGTH = 0x20010000-0x20008000

  /* Location for double reset detection, no init */
  DBL_RESET (rwx) :  ORIGIN = 0x20007F7C, LENGTH = 0x04

  /** Location of non initialized RAM. Non initialized RAM is used for exchanging bond information
   *  from application to bootloader when using buttonless DFU OTA. */
  NOINIT (rwx) :  ORIGIN = 0x20007F80, LENGTH = 0x80


  
  /** Location in UICR where bootloader start address is stored. */
  UICR_BOOTLOADER (r) : ORIGIN = 0x10001014, LENGTH = 0x04
  
  /** Location in UICR where mbr params page address is stored. */
  UICR_MBR_PARAM_PAGE(r) : ORIGIN = 0x10001018, LENGTH = 0x04
}

SECTIONS
{
  .fs_data_out ALIGN(4):
  {
    PROVIDE( __start_fs_data = .);
    KEEP(*(fs_data))
    PROVIDE( __stop_fs_data = .);
  } = 0

  /* Place the bootloader settings page in flash. */
  .bootloaderSettings(NOLOAD) :
  {
    
  } > BOOTLOADER_SETTINGS

  /* Write the bootloader address in UICR. */
  .uicrBootStartAddress : 
  {
    KEEP(*(.uicrBootStartAddress))
  } > UICR_BOOTLOADER
  
  /* Place the mbr params page in flash. */
    .mbrParamsPage(NOLOAD) :
  {
    
  } > MBR_PARAMS_PAGE
  
  /* Write the bootloader address in UICR. */
  .uicrMbrParamsPageAddress :
  {
    KEEP(*(.uicrMbrParamsPageAddress))
  } > UICR_MBR_PARAM_PAGE
  
  .dbl_reset(NOLOAD) :
  {

  } > DBL_RESET  

  /* No init RAM section in bootloader. Used for bond information exchange. */
  .noinit(NOLOAD) :
  {

  } > NOINIT
  /* other placements follow here... */
}

INCLUDE "nrf_common.ld"
