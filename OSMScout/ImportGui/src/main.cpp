/***************************************************************
 * Name:      OsmscoutImportGuiApp.cpp
 * Purpose:   Code for Application Class
 * Author:    Frans Schreuder (info@schreuderelectronics.com)
 * Created:   2015-05-29
 * Copyright: Frans Schreuder (www.schreuderelectronics.com)
 * License:
 **************************************************************/


#include "MapImportFrame.h"
#include "main.h"

IMPLEMENT_APP(OSMScoutImport);

bool OSMScoutImport::OnInit()
{
    MapImportFrame* frame = new MapImportFrame(0L);

    frame->Show();

    return true;
}
