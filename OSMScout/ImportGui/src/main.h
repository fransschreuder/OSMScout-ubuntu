/***************************************************************
 * Name:      OsmscoutImportGuiApp.h
 * Purpose:   Defines Application Class
 * Author:    Frans Schreuder (info@schreuderelectronics.com)
 * Created:   2015-05-29
 * Copyright: Frans Schreuder (www.schreuderelectronics.com)
 * License:
 **************************************************************/

#ifndef OSMSCOUTIMPORTGUIAPP_H
#define OSMSCOUTIMPORTGUIAPP_H

#include <wx/app.h>
#include <wx/wx.h>
class OSMScoutImport : public wxApp
{
    public:
        virtual bool OnInit();
};

#endif // OSMSCOUTIMPORTGUIAPP_H
